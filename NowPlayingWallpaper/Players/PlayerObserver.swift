import Foundation

final class PlayerObserver {
    private var notificationCenter = DistributedNotificationCenter.default()
    
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
        onTrackChange?()
        NotificationCenter.default.post(name: NSNotification.Name("TrackChanged"), object: nil)
    }
}
