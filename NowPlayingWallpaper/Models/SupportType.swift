import Cocoa

enum SupportType: String, CaseIterable, MenuRepresentable {
    case patreon = "Patreon"
    case boosty = "Boosty"
    case bymeacoffee = "By Me a Coffee"
    
    // MARK: - поля из протокола MenuRepresentable
    var title: String { self.rawValue }
    var action: Selector { #selector(MenuActions.openSupportURL(_:)) }
    // MARK: - необязательные поля протокола
    var url: URL? {
        switch self {
        case .patreon: return URL(string: "https://www.patreon.com")
        case .boosty: return URL(string: "https://boosty.to")
        case .bymeacoffee: return URL(string: "https://buymeacoffee.com")
        }
    }
}
