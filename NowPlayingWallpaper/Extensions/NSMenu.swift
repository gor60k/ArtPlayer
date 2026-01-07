import Cocoa

extension NSMenu {
    func restoreAllSelections() {
        let settings = SettingsService.shared
        
        // MARK: - Восстанавливления выбора отображения обоев
        if let wallpaperToggle = self.items.first(where: { $0.title == "Отображать как обои" }) {
            wallpaperToggle.state = settings.isWallpaperEnabled ? .on : .off
        }

        // MARK: - Восстанавливления выбора размещения обоев (по тегу)
        if let settingsItem = self.items.first(where : { $0.title == "Настройки"}),
           let settingsSubmenu = settingsItem.submenu {
            
            let savedLayout = settings.layout.rawValue
            settingsSubmenu.items.forEach { item in
                
                if item.action == #selector(MenuActions.changeLayout(_:)) {
                    item.state = (item.tag == savedLayout) ? .on : .off
                }
            }
        }
        // MARK: - Восстанавливление выбора Player (в подменю)
        if let playerItem = self.items.first(where: { $0.hasSubmenu }),
           let playerSubmenu = playerItem.submenu {
            
            let savedPlayerName = settings.selectedPlayer
            
            if let targetPlayerItem = playerSubmenu.items.first(where: { $0.title == savedPlayerName }) {
                playerSubmenu.items.forEach { $0.state = .off }
                targetPlayerItem.state = .on
            }
        }
    }
}
