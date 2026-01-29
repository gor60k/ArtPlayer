import Foundation
import AppKit

final class SpotifyPlayer: MusicPlayer {
    let appleScriptID = "com.spotify.client"
    
    func playPause() { excuteCommand("playpause") }
    func nextTrack() { excuteCommand("next track") }
    func previousTrack() { excuteCommand("previous track") }
    
    // MARK: - функция для получения информации о треке
    func fetchCurrentTrackInfo() async -> TrackInfo? {
        let scriptSource = """
        if application "\(appleScriptID)" is running then
            tell application "\(appleScriptID)" to return {name of current track, artist of current track, player state as string, player position as string, duration of current track}
        end if
        return nil
        """
            
        var error: NSDictionary?
        guard let script = NSAppleScript(source: scriptSource) else { return nil }
        let result = script.executeAndReturnError(&error)
        if error != nil { return nil }
        guard result.numberOfItems > 0 else { return nil }
                
        let track = result.atIndex(1)?.stringValue ?? "Неизвестно"
        let artist = result.atIndex(2)?.stringValue ?? "-"
        let state = result.atIndex(3)?.stringValue ?? "paused"
        let isPlaying = state.lowercased().contains("play") || state.contains("kPPl")
        
        let rawPosition = result.atIndex(4)?.stringValue ?? "0"
        let positionSeconds = Double(rawPosition.replacingOccurrences(of: ",", with: ".")) ?? 0
        let position = formatTime(positionSeconds)
        
        let durationMs = result.atIndex(5)?.doubleValue ?? 0
        let durationSeconds = durationMs / 1000
        let duration = formatTime(durationSeconds)
        
        return TrackInfo(title: track, artist: artist, isPlaying: isPlaying, position: position, duration: duration)
    }
    
    // MARK: - функция для получения обложки трека
    func fetchCurrentTrackArtwork() async -> NSImage? {
        guard let url = await fetchArtworkURL() else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return NSImage(data: data)
        } catch {
            print("Ошибка загрузки обложки из Spotify: \(error)")
            return nil
        }
    }
    
    // MARK: - функция для получения урла обложки (спотик отдает только путь до обложки)
    private func fetchArtworkURL() async -> URL? {
        let scriptSource = """
        if application "\(appleScriptID)" is running then
            tell application id "\(appleScriptID)"
                try
                    return (get artwork url of current track) as string
                on error
                    return ""
                end try
            end tell
        else
            return ""
        end if
        """
        
        return await MainActor.run {
            var error: NSDictionary?
            guard let script = NSAppleScript(source: scriptSource) else { return nil }
                  
            let descriptor = script.executeAndReturnError(&error)
            let urlString = descriptor.stringValue ?? ""
            
            if !urlString.isEmpty {
                return URL(string: urlString)
            }
            return nil
        }
    }
}
