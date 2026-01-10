import AppKit

final class WallpaperManager {
    static let shared = WallpaperManager()
    
    private let fileService = FileService()
    private var lastImage: NSImage?
    private let filePrefix = "wallpaper_"
    private let settings = SettingsService.shared
    
    // MARK: - функция обновления информации о плеере
    func update(with player: MusicPlayer?) {
        guard settings.isWallpaperEnabled else { return }
        
        Task {
            if let image = await player?.fetchCurrentTrackArtwork() {
                self.setWallpaper(from: image, scalingMode: self.settings.layout.scalingMode)
            }
        }
    }
    
    // MARK: - функция ставит конвертированное изображение на обои
    @MainActor
    func setWallpaper(from image: NSImage, scalingMode: NSImageScaling = .scaleProportionallyUpOrDown) {
        self.lastImage = image
        
        guard let data = image.jpegData else { return }
        
        guard let url  = fileService.saveToTemporaryFile(data: data, prefix: filePrefix, extenstion: "jpg") else { return }
        
        updateDesktopImage(url: url, scalingMode: scalingMode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fileService.cleanupFiles(matching: self.filePrefix, keepingURL: url)
        }
    }
    
    // MARK: - функция изменяет скейл мод
    @MainActor
    func changeScalingMode(to mode: NSImageScaling) {
        guard let image = lastImage else { return }
        setWallpaper(from: image, scalingMode: mode)
    }
    
    // MARK: - функция для обновления обоев
    private func updateDesktopImage(url: URL, scalingMode: NSImageScaling) {
        let screens = NSScreen.screens
        
        let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
            .imageScaling: scalingMode.rawValue,
            .allowClipping: true,
        ]
        
        for screen in screens {
            do {
                try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: options)
            } catch {
                print("Ошибка при установке обоев: \(error)")
            }
        }
    }
}
