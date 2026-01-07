import Foundation
import AppKit

final class AppleMusicPlayer: MusicPlayer {
    let name = "Music"
    
    private let AppleScript = """
    if application "Music" is running then
        tell application "Music"
            try
                if player state is playing then
                    set ardData to data pf artwork 1 of current track
                    return artData
                end if
            on error
                return ""
            end try
        end tell
    else
        tell application "Music" to launch
    end if
    return ""
    """
    
    func fetchCurrentTrackInfo() async -> TrackInfo? {
        let scriptSource = """
        if application "Music" is running then
            tell application "Music" to return {name of current track, artist of current track, player state as string}
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
    
    func fetchCurrentTrackArtwork() async -> NSImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let data = self.executeAppleScript(self.AppleScript),
                      let image = NSImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: image)
            }
        }
    }
    
    private func executeAppleScript(_ source: String) -> Data? {
        var error: NSDictionary?
        
        guard let script = NSAppleScript(source: source) else {
            return nil
        }
        
        let descriptor = script.executeAndReturnError(&error)
        
        return descriptor.data
    }
}
