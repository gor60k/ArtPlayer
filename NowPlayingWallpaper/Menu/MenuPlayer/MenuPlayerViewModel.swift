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
    @Published var positionSeconds: Double = 0
    @Published var durationSeconds: Double = 1
    
    private let actions = MenuActions.shared
    private var cancellables = Set<AnyCancellable>()
    private var positionTimer: AnyCancellable?

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
    
    private func startPositionTimer() {
        positionTimer?.cancel()
        
        positionTimer = Timer
            .publish(
                every: 1,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.updatePositionOnly()
                }
            }
    }
    
    private func stopPositionTimer() {
        positionTimer?.cancel()
        positionTimer = nil
    }
    
    func updatePositionOnly() async {
        guard let player = actions.currentPlayer else { return }
        
        let info = await player.fetchCurrentTrackInfo()
        self.position = info?.position ?? "0:00"
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
        
        if self.isPlaying {
            startPositionTimer()
        } else {
            stopPositionTimer()
        }
    }
}
