import Foundation
import AppKit
import Combine

@MainActor
final class MenuPlayerViewModel: ObservableObject {
    static let shared = MenuPlayerViewModel()
    private let playerObserver = PlayerObserver()
    
    @Published var trackTitle: String = "Загрузка..."
    @Published var artistName: String = "-"
    @Published var isPlaying: Bool = false
    @Published var artwork: NSImage? = nil
    @Published var position: String = "0:00"
    @Published var duration: String = "0:00"
    
    private let actions = MenuActions.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        Task { await updateStatus() }
    }

    // MARK: - функция для сетапа привязки действий плеера
    private func setupBindings() {
        NotificationCenter.default.publisher(for: NSNotification.Name("TrackChanged"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.updateStatus() }
            }
            .store(in: &cancellables)
    }

    // MARK: - функция обновления статуса трека в плеере
    func updateStatus() async {
        guard let player = actions.currentPlayer else { return }
        
        let info = await player.fetchCurrentTrackInfo()
        let newArtwork = await player.fetchCurrentTrackArtwork()
        
        print("информация о треке: \(info)")
        
        self.trackTitle = info?.title ?? "Загрузка..."
        self.artistName = info?.artist ?? "-"
        self.isPlaying = info?.isPlaying ?? false
        self.artwork = newArtwork
        self.position = info?.position ?? "0:00"
        self.duration = info?.duration ?? "0:00"
    }
}
