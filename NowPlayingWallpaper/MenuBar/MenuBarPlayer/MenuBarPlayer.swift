import Cocoa
import QuartzCore
import Combine

final class MenuBarPlayer: NSView {
    private let viewModel = MenuBarPlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let symbolConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)

    private let artworkView = NSImageView()
    private let trackLabel = NSTextField(labelWithString: "")
    private let artistLabel = NSTextField(labelWithString: "")
    private let playPauseButton = NSButton()
    private let gradientLayer = CAGradientLayer()
    private let visualEffectView = NSVisualEffectView()
    private let mainStack = NSStackView()

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 300, height: 80))
        setupBackground()
        setupLayout()
        bindViewModel()
    }

    required init?(coder: NSCoder) { fatalError() }

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
                self?.updatePlayPauseImage(isPlaying: isPlaying)
            }
            .store(in: &cancellables)

        viewModel.$artwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                
                let defaultImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
                self.artworkView.image = image ?? defaultImage
                
                self.updateGradient(with: image)
                
                self.artworkView.needsDisplay = true
                self.needsDisplay = true
            }
            .store(in: &cancellables)
    }

    private let bottomSeparator = NSView()
    
    private func updatePlayPauseImage(isPlaying: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        
        guard let newImage = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?
            .withSymbolConfiguration(symbolConfig) else { return }
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        playPauseButton.layer?.add(transition, forKey: kCATransition)
        playPauseButton.image = newImage
    }
    
    // MARK: - функция для сетапа бэка плеера
    private func setupBackground() {
        self.wantsLayer = true
    
        visualEffectView.frame = self.bounds
        visualEffectView.material = .menu
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        addSubview(visualEffectView)
        
        bottomSeparator.wantsLayer = true
        bottomSeparator.layer?.backgroundColor = NSColor.separatorColor.cgColor
        addSubview(bottomSeparator)

        let gradientView = NSView(frame: self.bounds)
        gradientView.wantsLayer = true
        gradientView.autoresizingMask = [.width, .height]
        
        gradientLayer.frame = gradientView.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [NSColor.clear.cgColor, NSColor.clear.cgColor]
        
        gradientView.layer?.addSublayer(gradientLayer)
        addSubview(gradientView)
    }

    // MARK: - функция для сетапа разметки плеера
    private func setupLayout() {
        artworkView.wantsLayer = true
        artworkView.layer?.cornerRadius = 8
        
        trackLabel.font = .systemFont(ofSize: 13, weight: .bold)
        trackLabel.lineBreakMode = .byTruncatingTail
        trackLabel.usesSingleLineMode = true
        
        artistLabel.font = .systemFont(ofSize: 11)
        artistLabel.textColor = .secondaryLabelColor
        artistLabel.lineBreakMode = .byTruncatingTail
        artistLabel.usesSingleLineMode = true
        
        let prevBtn = NSButton.createSymbol(name: "backward.fill", target: MenuActions.shared, action: #selector(MenuActions.prevTrack), config: symbolConfig)
        let nextBtn = NSButton.createSymbol(name: "forward.fill", target: MenuActions.shared, action: #selector(MenuActions.nextTrack), config: symbolConfig)
        
        playPauseButton.isBordered = false
        playPauseButton.wantsLayer = true
        playPauseButton.target = MenuActions.shared
        playPauseButton.action = #selector(MenuActions.togglePlayPause)
        playPauseButton.title = ""
        
        let controls = NSStackView(views: [prevBtn, playPauseButton, nextBtn])
        controls.spacing = 15
        
        let info = NSStackView(views: [trackLabel, artistLabel, controls])
        info.orientation = .vertical
        info.alignment = .leading
        info.spacing = 4
        
        trackLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        artistLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        mainStack.addArrangedSubview(artworkView)
        mainStack.addArrangedSubview(info)
        mainStack.edgeInsets = NSEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        mainStack.spacing = 15
        mainStack.alignment = .centerY
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 300),
        
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
                
            artworkView.widthAnchor.constraint(equalToConstant: 60),
            artworkView.heightAnchor.constraint(equalToConstant: 60),
            
            prevBtn.widthAnchor.constraint(equalToConstant: 24),
            playPauseButton.widthAnchor.constraint(equalToConstant: 24),
            nextBtn.widthAnchor.constraint(equalToConstant: 24),
        ])
    }

    // MARK: - функция обновления градиента
    private func updateGradient(with image: NSImage?) {
        let colors = image?.extractColors() ?? [NSColor.clear.cgColor, NSColor.clear.cgColor]
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.2)
        gradientLayer.colors = colors
        CATransaction.commit()
        
        self.gradientLayer.setNeedsDisplay()
    }
}
