import Cocoa
import AppKit

protocol MusicPlayer {
    var appleScriptID: String { get }
    
    func fetchCurrentTrackInfo() async -> TrackInfo?
    func fetchCurrentTrackArtwork() async -> NSImage?
    
    func playPause()
    func nextTrack()
    func previousTrack()
}

struct TrackInfo {
    let title: String
    let artist: String
    let isPlaying: Bool
}

extension MusicPlayer {
    func excuteCommand(_ command: String) {
        let script = "if application \"\(appleScriptID)\" is running then tell application \"\(appleScriptID)\" to \(command)"
        
        DispatchQueue.global(qos: .userInitiated).async {
            NSAppleScript(source: script)?.executeAndReturnError(nil)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("TrackChanged"), object: nil)
            }
        }
    }
}

