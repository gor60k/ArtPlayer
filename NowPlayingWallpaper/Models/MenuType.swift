import Cocoa

enum LayoutOption: String, CaseIterable, MenuRepresentable {
    case fillScreen = "Заполнить весь экран" // Tag 0
    case fullScreen = "Во весь экран"      // Tag 1
    case screenSize = "По размеру экрана"  // Tag 2
    case center     = "По центру"          // Tag 3
    case mosaic     = "Мозаика"            // Tag 4
    
    var title: String { self.rawValue }
    
    var tag: Int {
        switch self {
        case .fillScreen: return 0
        case .fullScreen: return 1
        case .screenSize: return 2
        case .center:     return 3
        case .mosaic:     return 4
        }
    }
    
    var action: Selector { #selector(MenuActions.changeLayout(_:)) }
}
