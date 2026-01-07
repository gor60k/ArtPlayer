import Cocoa

enum LayoutType: Int {
    case fit = 0
    case stretch = 1
    case center = 2

    var scalingMode: NSImageScaling {
        switch self {
        case .fit: return .scaleProportionallyDown
        case .center: return .scaleNone
        default: return .scaleAxesIndependently
        }
    }
}
