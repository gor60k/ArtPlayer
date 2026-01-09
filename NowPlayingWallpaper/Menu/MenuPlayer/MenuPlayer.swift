import Cocoa
import QuartzCore
import Combine

final class MenuPlayer: NSView {
    private let viewModel = MenuPlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let symbolConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
    
    private let backgroundView = MenuPlayerBackgroundView()
    private let artworkView = NSImageView()
    private let trackLabel = NSTextField.createTrackLabel()
    private let artistLabel = NSTextField.createArtistLabel()
    private lazy var controls = MenuPlayerControlsStack(target: MenuActions.shared, config: symbolConfig)
    private let bottomSeparator = NSView()

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 300, height: 80))
        setupUI()
        bindViewModel()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - построение UI
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomSeparator.wantsLayer = true
        bottomSeparator.layer?.backgroundColor = NSColor.separatorColor.cgColor
        addSubview(bottomSeparator)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        artworkView.wantsLayer = true
        artworkView.layer?.cornerRadius = 8
            
        let infoStack = NSStackView(views: [trackLabel, artistLabel, controls])
        infoStack.orientation = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 4

        let mainStack = NSStackView(views: [artworkView, infoStack])
        mainStack.edgeInsets = NSEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        mainStack.spacing = 15
        mainStack.alignment = .centerY
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                    
            artworkView.widthAnchor.constraint(equalToConstant: 60),
            artworkView.heightAnchor.constraint(equalToConstant: 60),
            
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - функция для связи вьюва и интерфейса
    private func bindViewModel() {
        cancellables.removeAll()
        
        viewModel.$trackTitle
            .receive(on: DispatchQueue.main)
            .assign(to: \.stringValue, on: trackLabel)
            .store(in: &cancellables)
        
        viewModel.$artistName
            .receive(on: DispatchQueue.main)
            .assign(to: \.stringValue, on: artistLabel)
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
            .withSymbolConfiguration(symbolConfig)
            
        controls.playPauseBtn.image = img
    }
}
