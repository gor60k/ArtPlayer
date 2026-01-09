import Cocoa
import QuartzCore
import Combine

final class MenuPlayer: NSView {
    private let viewModel = MenuPlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let playConfig = NSImage.SymbolConfiguration(pointSize: 22, weight: .bold)
    private let buttonConfig = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
    
    private let backgroundView = MenuPlayerBackgroundView()
    private let artworkView = NSImageView()
    private let info = MenuPlayerInfoStackView()
    private lazy var controls = MenuPlayerControlsStack(target: MenuActions.shared, playConfig: playConfig, buttonConfig: buttonConfig)
    private let bottomSeparator = NSView()

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 340, height: 120))
        setupUI()
        bindViewModel()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - построение UI
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomSeparator.wantsLayer = true
        bottomSeparator.layer?.backgroundColor = NSColor.separatorColor.cgColor
        addSubview(bottomSeparator)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        artworkView.wantsLayer = true
        artworkView.layer?.cornerRadius = 8
        
        let infoControls = NSStackView(views: [info, controls])
        infoControls.orientation = .vertical
        infoControls.alignment = .left

        let mainStack = NSStackView(views: [artworkView, infoControls])
        mainStack.edgeInsets = NSEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        mainStack.spacing = 15
        mainStack.alignment = .top
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 340),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
                    
            artworkView.widthAnchor.constraint(equalToConstant: 100),
            artworkView.heightAnchor.constraint(equalToConstant: 100),
            
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor)
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
