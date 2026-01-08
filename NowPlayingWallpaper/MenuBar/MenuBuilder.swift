import Cocoa

final class MenuBuilder {
    private let actions: MenuActions
    
    init(actions: MenuActions = .shared) {
        self.actions = actions
    }
    
    func build(with PlayerView: NSView) -> NSMenu {
        let menu = NSMenu()
        
        let playerItem = NSMenuItem()
        playerItem.view = PlayerView
        menu.addItem(playerItem)
        
        menu.addItem(createSubmenuItem(
            title: "Выбрать плеер",
            options: PlayerType.allCases,
            selectedTitle: SettingsService.shared.selectedPlayer
        ))
        
        let wallpaperToggle = NSMenuItem(
            title: "Отображать как обои",
            action: #selector(MenuActions.toggleWallpaper(_:)),
            keyEquivalent: ""
        )
        wallpaperToggle.target = actions
        wallpaperToggle.state = SettingsService.shared.isWallpaperEnabled ? .on : .off
        menu.addItem(wallpaperToggle)
        
        menu.addItem(createSubmenuItem(
            title: "Настройки обоев",
            options: MenuType.allCases
        ))
        
        menu.addItem(createSubmenuItem(
            title: "Поддержать автора",
            options: SupportType.allCases
        ))
        
        menu.addItem(.separator())
        
        menu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate),
            keyEquivalent: "q"
        )
                
        return menu
    }
    
    private func createSubmenuItem(title: String, options: [MenuRepresentable], selectedTitle: String? = nil) -> NSMenuItem {
        let submenu = NSMenu()
        for option in options {
            let item = NSMenuItem(title: option.title, action: option.action, keyEquivalent: option.keyEquivalent)
            item.target = actions
            item.tag = option.tag
            item.representedObject = option
            
            if let selected = selectedTitle , option.title == selected {
                item.state = .on
            }
            submenu.addItem(item)
        }
        
        let menuitem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuitem.submenu = submenu
        return menuitem
    }
}
