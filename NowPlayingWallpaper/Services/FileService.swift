import Foundation

final class FileService {
    static let shared = FileService()
    private let fileManager = FileManager.default
    
    // MARK: - каталог для кэширования
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - функция сохранения временного файла
    func saveToTemporaryFile(data: Data, prefix: String, extenstion ext: String) -> URL? {
        let fileName = "\(prefix)\(UUID().uuidString).\(ext)"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Ошибка сохранения: \(error)")
            return nil
        }
    }
    
    // MARK: - функция для очистки файлов
    func cleanupFiles(matching prefic: String, keepingURL: URL? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let files = (try? self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil)) ?? []
            
            for file in files where file.lastPathComponent.hasPrefix(prefic) {
                if let keepingURL = keepingURL, file == keepingURL { continue }
                
                try? self.fileManager.removeItem(at: file)
            }
        }
    }
}
