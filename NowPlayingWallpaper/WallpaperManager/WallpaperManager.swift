import AppKit

final class WallpaperManager {
    
    // MARK: - приватные переменные
    private var fileManager = FileManager.default
    private var lastImage: NSImage?
    private let filePrefix = "wallpaper_"
    // MARK: - публичные методы
    func setWallpaper(from image: NSImage, scalingMode: NSImageScaling = .scaleProportionallyUpOrDown) {
        self.lastImage = image
        self.apply(image: image, scalingMode: scalingMode)
    }
    
    func changeScalingMode(to mode: NSImageScaling) {
        guard let image = lastImage else { return }
        self.apply(image: image, scalingMode: mode)
    }
    // MARK: - функция, которая применяет обои
    private func apply(image: NSImage, scalingMode: NSImageScaling) {
        guard let pngData = converToPNG(image: image) else { return }
        
        cleanupOldWallpapers()
        
        guard let tempURL = saveToTemporaryFile(data: pngData) else { return }
        
        updateDesktopImage(url: tempURL, scalingMode: scalingMode)
    }
    // MARK: - функция для конвертации изображений
    private func converToPNG(image: NSImage) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
    // MARK: - функция для очистки старых обоев
    private func cleanupOldWallpapers() {
        let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for file in files where file.lastPathComponent.hasPrefix(filePrefix) {
                try? fileManager.removeItem(at: file)
            }
        } catch {
            print("Ошибка очистки старых обоев: \(error)")
        }
    }
    // MARK: - функция для сохранения во временный файл
    private func saveToTemporaryFile(data: Data) -> URL? {
        let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = "\(filePrefix)\(UUID().uuidString).png"
        let fileURL = cacheURL.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Ошибка сохранения: \(error)")
            return nil
        }
    }
    // MARK: - функция для обновления обоев
    private func updateDesktopImage(url: URL, scalingMode: NSImageScaling) {
        guard let screen = NSScreen.main else { return }
        
        let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
            .imageScaling: scalingMode.rawValue,
            .allowClipping: true
        ]
        
        DispatchQueue.main.async {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: options)
        }
    }
}
