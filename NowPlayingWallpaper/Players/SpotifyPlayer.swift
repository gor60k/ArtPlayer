import Foundation
import AppKit

final class SpotifyPlayer: MusicPlayer {
    let name = "Spotify"
    
    // MARK: - скрипт для подключения к плееру
    private let AppleScript = """
    if application "Spotify" is running then
        tell application id "com.spotify.client"
            try
                set theURL to (get artwork url of current track)
                return theURL as string
            on error
                return ""
            end try
        end tell
    else
        tell application id "com.spotify.client" to launch
        return ""
    end if
    """
    
    // MARK: - функция для получения информации о треке
    func fetchCurrentTrackInfo() async -> TrackInfo? {
        let scriptSource = """
        if application "Spotify" is running then
            tell application "Spotify" to return {name of current track, artist of current track, player state as string}
        end if
        return nil
        """
            
        let script = NSAppleScript(source: scriptSource)
        var error: NSDictionary?
        guard let result = script?.executeAndReturnError(&error) else { return nil }
            
        let track = result.atIndex(1)?.stringValue ?? "Неизвестно"
        let artist = result.atIndex(2)?.stringValue ?? "-"
        let state = result.atIndex(3)?.stringValue ?? "paused"
        let isPlaying = state.lowercased().contains("play") || state.contains("kPPl")
            
        return TrackInfo(title: track, artist: artist, isPlaying: isPlaying)
    }
    
    // MARK: - функция для получения обложки трека
    func fetchCurrentTrackArtwork() async -> NSImage? {
        let url = await fetchArtworkURL()
        guard let url = url else { return nil }
        
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
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self  = self else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let artworkURLString = self.executeAppleScript(self.AppleScript)
                
                if !artworkURLString.isEmpty, let url = URL(string: artworkURLString) {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - функция для использования эппловского скрипта
    private func executeAppleScript(_ source: String) -> String {
        var error: NSDictionary?
        
        if let script = NSAppleScript(source: source) {
            let descriptor = script.executeAndReturnError(&error)
            return descriptor.stringValue ?? ""
        }
        return ""
    }
}
