import Cocoa

final class MenuActions: NSObject {
    static let shared = MenuActions()
    
    private let spotifyPlayer = SpotifyPlayer()
    private let appleMusicPlayer = AppleMusicPlayer()
    private let wallpaperManager = WallpaperManager()
    private let observer = PlayerObserver()
    private let settings = SettingsService.shared
    
    var currentPlayer: MusicPlayer? {
        settings.selectedPlayer == "Spotify" ? spotifyPlayer : appleMusicPlayer
    }

    override init() {
        super.init()
        setupObserver()
    }
    
    private func setupObserver() {
        observer.onTrackChange = { [weak self] in
            guard let self = self else { return }
            
            if self.settings.isWallpaperEnabled {
                self.wallpaperManager.update(with: self.currentPlayer)
            }
        }
    }
    
    // MARK: - действия контроллеров плеера
    @objc func togglePlayPause() {
        currentPlayer?.playPause()
    }
    
    @objc func nextTrack() {
        currentPlayer?.nextTrack()
    }
    
    @objc func prevTrack() {
        currentPlayer?.previousTrack()
    }
    
    // MARK: - действия пунктов меню
    @objc func toggleWallpaper(_ sender: NSMenuItem) {
        sender.state = (sender.state == .on) ? .off : .on
        settings.isWallpaperEnabled = (sender.state == .on)
        if settings.isWallpaperEnabled { wallpaperManager.update(with: currentPlayer) }
    }
    
    @objc func selectPlayer(_ sender: NSMenuItem) {
        updateMenuSelection(sender)
        settings.selectedPlayer = sender.title
        NotificationCenter.default.post(name: NSNotification.Name("TrackChanged"), object: nil)
        wallpaperManager.update(with: currentPlayer)
    }
    
    @objc func changeLayout(_ sender: NSMenuItem) {
        updateMenuSelection(sender)
        let newLayout = LayoutType(rawValue: sender.tag) ?? .fit
        settings.layout = newLayout
        wallpaperManager.changeScalingMode(to: newLayout.scalingMode)
    }
    
    @objc func openSupportURL(_ sender: NSMenuItem) {
        print("пенисы")
        guard let item = sender.representedObject as? SupportType,
              let url = item.url else { return }
        
        NSWorkspace.shared.open(url)
    }
    
    private func updateMenuSelection(_ item: NSMenuItem) {
        item.menu?.items.forEach { $0.state = .off }
        item.state = .on
    }
}
