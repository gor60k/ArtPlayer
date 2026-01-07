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
                self.updateWallpaper()
            }
        }
    }
    
    // MARK: - действия контроллеров плеера
    @objc func togglePlayPause() {
        execute("playpause", notify: true)
    }
    
    @objc func nextTrack() {
        execute("next track", notify: true)
    }
    
    @objc func prevTrack() {
        execute("previous track", notify: true)
    }
    
    private func execute(_ action: String, notify: Bool = false) {
        let app = settings.selectedPlayer == "Apple Music" ? "Music" : "Spotify"
        let script = "if application \"\(app)\" is running then tell application \"\(app)\" to \(action)"
        
        DispatchQueue.global(qos: .userInitiated).async {
            NSAppleScript(source: script)?.executeAndReturnError(nil)
            
            if notify {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NotificationCenter.default.post(name: NSNotification.Name("TrackChanged"), object: nil)
                }
            }
        }
    }

    func updateWallpaper() {
        guard settings.isWallpaperEnabled else { return }
        Task {
            if let image = await currentPlayer?.fetchCurrentTrackArtwork() {
                await MainActor.run {
                    self.wallpaperManager.setWallpaper(from: image, scalingMode: self.settings.layout.scalingMode)
                }
            }
        }
    }
    
    // MARK: - действия пунктов меню
    @objc func toggleWallpaper(_ sender: NSMenuItem) {
        sender.state = (sender.state == .on) ? .off : .on
        settings.isWallpaperEnabled = (sender.state == .on)
        if settings.isWallpaperEnabled { updateWallpaper() }
    }
    
    @objc func selectPlayer(_ sender: NSMenuItem) {
        updateMenuSelection(sender)
        settings.selectedPlayer = sender.title
        NotificationCenter.default.post(name: NSNotification.Name("TrackChanged"), object: nil)
        updateWallpaper()
    }
    
    @objc func changeLayout(_ sender: NSMenuItem) {
        updateMenuSelection(sender)
        let newLayout = LayoutType(rawValue: sender.tag) ?? .fit
        settings.layout = newLayout
        wallpaperManager.changeScalingMode(to: newLayout.scalingMode)
    }
    
    private func updateMenuSelection(_ item: NSMenuItem) {
        item.menu?.items.forEach { $0.state = .off }
        item.state = .on
    }
}
