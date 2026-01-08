import Cocoa

enum PlayerType: String, CaseIterable, MenuRepresentable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    
    // MARK: - поля из протокола MenuRepresentable
    var title: String { self.rawValue }
    var action: Selector { #selector(MenuActions.selectPlayer(_:)) }
    // MARK: - необязательные поля протокола
    var keyEquivalent: String {
        switch self {
        case .spotify: return "s"
        case .appleMusic: return "m"
        }
    }
}
