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
        
        if let info = await player.fetchCurrentTrackInfo() {
            self.trackTitle = info.title
            self.artistName = info.artist
            self.isPlaying = info.isPlaying
        }
    
        self.artwork = await player.fetchCurrentTrackArtwork()
    }
}
