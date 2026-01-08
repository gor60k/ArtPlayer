import Cocoa

enum MenuType: String, CaseIterable, MenuRepresentable {
    case fullScreen = "Во весь экран"
    case screenSize = "По размеру экрана"
    case center     = "По центру"
    
    // MARK: - поля из протокола MenuRepresentable
    var title: String { self.rawValue }
    var action: Selector { #selector(MenuActions.changeLayout(_:)) }
    // MARK: - необязательные поля протокола
    var tag: Int {
        switch self {
        case .fullScreen: return 0
        case .screenSize: return 1
        case .center:     return 2
        }
    }
}
