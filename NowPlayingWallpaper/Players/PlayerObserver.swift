import Foundation

final class PlayerObserver {
    private var notificationCenter = DistributedNotificationCenter.default()
    
    // Замыкание для обратной связи с MenuActions
    var onTrackChange: (() -> Void)?
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        let spotify = NSNotification.Name("com.spotify.client.PlaybackStateChanged")
        let appleMusic = NSNotification.Name("com.apple.Music.playerInfo")
        
        notificationCenter.addObserver(forName: spotify, object: nil, queue: .main) { [weak self] _ in
            self?.handleNotification()
        }
        
        notificationCenter.addObserver(forName: appleMusic, object: nil, queue: .main) { [weak self] _ in
            self?.handleNotification()
        }
    }
    
    private func handleNotification() {
        // 1. Уведомляем локально через замыкание (для обоев)
        onTrackChange?()
        // 2. Рассылаем глобальный сигнал (для ViewModel)
        NotificationCenter.default.post(name: NSNotification.Name("TrackChanged"), object: nil)
    }
}
