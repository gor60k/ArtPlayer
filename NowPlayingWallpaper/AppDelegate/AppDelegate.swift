import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Сразу делаем приложение системным (в строке меню)
        NSApp.setActivationPolicy(.accessory)
        
        // 2. Инициализируем синглтоны (логику) до создания интерфейса
        _ = SettingsService.shared
        _ = MenuActions.shared
        
        // 3. Создаем контроллер меню (который создаст UI)
        menuBarController = MenuBarController()
        
        // 4. Безопасно восстанавливаем состояние галочек в меню
        if let menu = menuBarController?.statusItem.menu {
            menu.restoreAllSelections()
        }
        
        // 5. Запускаем обновление обоев, если они включены
        MenuActions.shared.updateWallpaper()
    }
}
