import Cocoa

enum PlayerType: String, CaseIterable, MenuRepresentable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    
    var title: String { self.rawValue }
    
    var keyEquivalent: String {
        switch self {
        case .spotify: return "s"
        case .appleMusic: return "m"
        }
    }
    
    var action: Selector { #selector(MenuActions.selectPlayer(_:)) }
}
