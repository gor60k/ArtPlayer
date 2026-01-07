import Cocoa

enum MenuType: String, CaseIterable, MenuRepresentable {
    case fullScreen = "Во весь экран"
    case screenSize = "По размеру экрана"
    case center     = "По центру"
    
    var title: String { self.rawValue }
    
    var tag: Int {
        switch self {
        case .fullScreen: return 0
        case .screenSize: return 1
        case .center:     return 2
        }
    }
    
    var action: Selector { #selector(MenuActions.changeLayout(_:)) }
}
