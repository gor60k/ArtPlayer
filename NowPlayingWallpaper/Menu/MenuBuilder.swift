import Cocoa

final class MenuBuilder: NSObject, NSMenuDelegate {
    private let actions: MenuActions
    private let spotifyPlayer = SpotifyPlayer()
    private let appleMusicPlayer = AppleMusicPlayer()
    private let settings = SettingsService.shared
    var currentPlayer: MusicPlayer? {
        settings.selectedPlayer == "Spotify" ? spotifyPlayer : appleMusicPlayer
    }
    
    init(actions: MenuActions = .shared) {
        self.actions = actions
    }
    
    func build() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        
        let playerSectionHeader = NSMenuItem.sectionHeader(title: "Плеер")
        menu.addItem(playerSectionHeader)
        
        menu.addItem(createSubmenuItem(
            title: "Выбрать плеер",
            options: PlayerType.allCases,
            selectedTitle: SettingsService.shared.selectedPlayer
        ))
        
        let playlistItem = NSMenuItem(
            title: "Добавить трек",
            action: nil,
            keyEquivalent: ""
        )
        playlistItem.target = actions
        menu.addItem(playlistItem)
        
        menu.addItem(.separator())
        
        let wallpaperSectionHeader = NSMenuItem.sectionHeader(title: "Обои")
        menu.addItem(wallpaperSectionHeader)
        
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
        
        menu.addItem(.separator())
        
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
