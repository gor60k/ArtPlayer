import Foundation
import AppKit
import Combine

@MainActor
final class MenuBarPlayerViewModel: ObservableObject {
    static let shared = MenuBarPlayerViewModel()
    
    @Published var trackTitle: String = "Загрузка..."
    @Published var artistName: String = "-"
    @Published var isPlaying: Bool = false
    @Published var artwork: NSImage? = nil
    
    private let actions = MenuActions.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        // Начальное обновление при запуске
        Task { await updateStatus() }
    }

    private func setupBindings() {
        // Подписываемся на уведомление "TrackChanged", которое шлет PlayerObserver или MenuActions
        NotificationCenter.default.publisher(for: NSNotification.Name("TrackChanged"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.updateStatus() }
            }
            .store(in: &cancellables)
    }

    func updateStatus() async {
        guard let player = actions.currentPlayer else { return }
        
        // Получаем инфо
        if let info = await player.fetchCurrentTrackInfo() {
            self.trackTitle = info.title
            self.artistName = info.artist
            self.isPlaying = info.isPlaying
        }
        
        // Получаем обложку
        self.artwork = await player.fetchCurrentTrackArtwork()
    }
}
