import Foundation
import AppKit

final class AppleMusicPlayer: MusicPlayer {
    let appleScriptID = "Music"
    
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
        let duration = "0:00"
        let position = "0:00"
        
            
        return TrackInfo(title: track, artist: artist, isPlaying: isPlaying, position: position, duration: duration)
    }
    
    // MARK: - функция для получения обложки трека
    func fetchCurrentTrackArtwork() async -> NSImage? {
        let scriptSource = """
        if application "\(appleScriptID)" is running then
            tell application "Music"
                try
                    if exists (artwork 1 of current track) then
                        return data of artwork 1 of current track
                    end if
                end try
            end tell
        end if
        return nil
        """
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var error: NSDictionary?
                
                guard let script = NSAppleScript(source: scriptSource) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let result = script.executeAndReturnError(&error)
                if error == nil && result.descriptorType != typeNull {
                    let data = result.data
                    if !data.isEmpty, let image = NSImage(data: data) {
                        continuation.resume(returning: image)
                        return
                    }
                }
                
                continuation.resume(returning: nil)
            }
        }
    }
}
