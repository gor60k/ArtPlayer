import Cocoa

// MARK: - в этом классе собирается приложение
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var menuController: MenuController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        _ = SettingsService.shared
        let actions = MenuActions.shared
        let wallpaper = WallpaperManager.shared
        
        menuController = MenuController()
            
        if let menu = menuController?.statusItem.menu {
            menu.restoreAllSelections()
        }
        
        wallpaper.update(with: actions.currentPlayer)
    }
}
