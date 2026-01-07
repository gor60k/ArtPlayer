import Cocoa
import AppKit

protocol MusicPlayer {
    var name: String { get }
    func fetchCurrentTrackInfo() async -> TrackInfo?
    func fetchCurrentTrackArtwork() async -> NSImage?
}

struct TrackInfo {
    let title: String
    let artist: String
    let isPlaying: Bool
}

