import Cocoa
import QuartzCore
import Combine

final class MenuPlayer: NSView {
    private let viewModel = MenuPlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let playConfig = NSImage.SymbolConfiguration(pointSize: 22, weight: .bold)
    private let buttonConfig = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
    
    private let settingsButton = NSButton()
    private let backgroundView = MenuPlayerBackgroundView()
    private let artworkView = NSImageView()
    private let info = MenuPlayerInfoStackView()
    private lazy var controls = MenuPlayerControlsStack(target: MenuActions.shared, playConfig: playConfig, buttonConfig: buttonConfig)
    private let slider = MenuPlayerSlider()

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 340, height: 140))
        setupUI()
        bindViewModel()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - построение UI
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        artworkView.wantsLayer = true
        artworkView.layer?.cornerRadius = 8
        artworkView.imageScaling = .scaleProportionallyUpOrDown
        
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let rightContainer = NSStackView(views: [info, controls, slider])
        rightContainer.orientation = .vertical
        rightContainer.alignment = .leading
        rightContainer.spacing = 10
        rightContainer.edgeInsets = NSEdgeInsets(top: 15, left: 0, bottom: 30, right: 0)
        rightContainer.distribution = .fill
        
        let mainStack = NSStackView(views: [artworkView, rightContainer])
        mainStack.orientation = .horizontal
        mainStack.alignment = .top
        mainStack.spacing = 15
        mainStack.edgeInsets = NSEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.distribution = .fill
                
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            info.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            
            rightContainer.topAnchor.constraint(equalTo: mainStack.topAnchor),
            rightContainer.bottomAnchor.constraint(equalTo: mainStack.bottomAnchor),
            
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            artworkView.widthAnchor.constraint(equalToConstant: 110),
            artworkView.heightAnchor.constraint(equalToConstant: 110),
            
            
        ])
    }

    // MARK: - функция для связи вьюва и интерфейса
    private func bindViewModel() {
        cancellables.removeAll()
        
        Publishers.CombineLatest(viewModel.$trackTitle, viewModel.$artistName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trackTitle, artistName in
                self?.info.update(title: trackTitle, artist: artistName)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.$position, viewModel.$duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] position, duration in
                self?.slider.update(position: position, duration: duration)
            }
            .store(in: &cancellables)

        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.updatePlayPauseState(isPlaying)
            }
            .store(in: &cancellables)

        viewModel.$artwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.artworkView.image = image ?? NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
                let colors = image?.extractColors() ?? [NSColor.clear.cgColor, NSColor.clear.cgColor]
                self?.backgroundView.updateGradient(with: colors)
            }
            .store(in: &cancellables)
    }
    
    private func updatePlayPauseState(_ isPlaying: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        let img = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?
            .withSymbolConfiguration(playConfig)
            
        controls.playPauseBtn.image = img
    }
}
