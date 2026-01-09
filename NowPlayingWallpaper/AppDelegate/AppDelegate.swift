import Cocoa

// MARK: - в этом классе собирается приложение
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        _ = SettingsService.shared
        let actions = MenuActions.shared
        let wallpaper = WallpaperManager.shared
        
        menuBarController = MenuBarController()
            
        if let menu = menuBarController?.statusItem.menu {
            menu.restoreAllSelections()
        }
        
        wallpaper.update(with: actions.currentPlayer)
    }
}
