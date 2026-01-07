import Cocoa
import Combine

final class MenuBarController: NSObject, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var playerView: MenuBarPlayer = {
        let view = MenuBarPlayer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init() {
        super.init()
        setupMenuButton()
        setupMenu()
        setupObserver()
    }
    
    private func setupObserver() {
        MenuBarPlayerViewModel.shared.$artwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.statusItem.menu?.update()
            }
            .store(in: &cancellables)
        
        MenuBarPlayerViewModel.shared.$trackTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.statusItem.menu?.update()
            }
            .store(in: &cancellables)
    }
    
    private func setupMenuButton() {
        statusItem.button?.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Now Playing")
    }
    
    // MARK: - функция для сетапа меню в строке меню
    private func setupMenu() {
        let menu = NSMenu()
        menu.delegate = self
        
        let playerItem = NSMenuItem()
        playerItem.view = playerView
        menu.addItem(playerItem)
        
        let playerSubmenu = NSMenu()
        addItems(PlayerType.allCases, to: playerSubmenu)
        let playerSelector = NSMenuItem(title: "Выбрать плеер", action: nil, keyEquivalent: "")
        playerSelector.submenu = playerSubmenu
        menu.addItem(playerSelector)
        
        let wallpaperToggleItem = NSMenuItem(
            title: "Отображать как обои",
            action: #selector(MenuActions.toggleWallpaper(_:)),
            keyEquivalent: ""
        )
        wallpaperToggleItem.target = MenuActions.shared
        wallpaperToggleItem.state = SettingsService.shared.isWallpaperEnabled ? .on : .off
        menu.addItem(wallpaperToggleItem)
        
        let settingsSubmenu = NSMenu()
        addItems(MenuType.allCases, to: settingsSubmenu)
        let settingsItem = NSMenuItem(title: "Настройки обоев", action: nil, keyEquivalent: "")
        settingsItem.submenu = settingsSubmenu
        menu.addItem(settingsItem)
        
        menu.addItem(.separator())
        
        menu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate),
            keyEquivalent: "q"
        )

        statusItem.menu = menu
    }
    
    // MARK: - функция для преждевременного открытия меню
    func menuWillOpen(_ menu: NSMenu) {
        Task {
            await MenuBarPlayerViewModel.shared.updateStatus()
        }
    }
    
    // MARK: - для более удобного добавления итемов меню
    private func addItems(_ options: [MenuRepresentable], to menu: NSMenu) {
        for option in options {
            let item = NSMenuItem(title: option.title, action: option.action, keyEquivalent: option.keyEquivalent)
            item.target = MenuActions.shared
            item.tag = option.tag
            if option.title == SettingsService.shared.selectedPlayer {
                item.state = .on
            }
            menu.addItem(item)
        }
    }
}
