import Foundation

final class SettingsService {
    static let shared = SettingsService()
    private let defaults = UserDefaults.standard

    var selectedPlayer: String {
        get { defaults.string(forKey: "SelectedPlayerName") ?? PlayerType.spotify.rawValue }
        set { defaults.set(newValue, forKey: "SelectedPlayerName") }
    }

    var layout: LayoutType {
        get { LayoutType(rawValue: defaults.integer(forKey: "SelectedScalingMode")) ?? .fit }
        set { defaults.set(newValue.rawValue, forKey: "SelectedScalingMode") }
    }
    
    var isWallpaperEnabled: Bool {
        get { defaults.bool(forKey: "IsWallpaperEnabled") }
        set { defaults.set(newValue, forKey: "IsWallpaperEnabled") }
    }
}
