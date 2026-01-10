import Cocoa

// MARK: - в этом классе собирается приложение
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var popover: PopoverManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        _ = SettingsService.shared
        let actions = MenuActions.shared
        let wallpaper = WallpaperManager.shared
        
        popover = PopoverManager.shared
        
        wallpaper.update(with: actions.currentPlayer)
    }
}
