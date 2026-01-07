import Cocoa

enum WallpaperLayout: Int {
    case fill = 0
    case fit = 1
    case stretch = 2
    case center = 3

    var scalingMode: NSImageScaling {
        switch self {
        case .fit: return .scaleProportionallyDown
        case .stretch: return .scaleAxesIndependently
        case .center: return .scaleNone
        default: return .scaleProportionallyUpOrDown
        }
    }
}
