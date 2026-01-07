import Cocoa
import QuartzCore
import Combine

final class MenuBarPlayer: NSView {
    private let viewModel = MenuBarPlayerViewModel.shared
        private var cancellables = Set<AnyCancellable>()
    private let symbolConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)

    // UI Elements
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

    private func bindViewModel() {
        // Привязываем текст трека
        viewModel.$trackTitle
            .receive(on: RunLoop.main)
            .assign(to: \.stringValue, on: trackLabel)
            .store(in: &cancellables)

        // Привязываем артиста
        viewModel.$artistName
            .receive(on: RunLoop.main)
            .assign(to: \.stringValue, on: artistLabel)
            .store(in: &cancellables)

        // Привязываем иконку Play/Pause
        viewModel.$isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] isPlaying in
                guard let self = self else { return }
                let iconName = isPlaying ? "pause.fill" : "play.fill"
                
                // Исправление 1: Используем базовое изображение и применяем конфиг отдельно
                if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
                    self.playPauseButton.image = image.withSymbolConfiguration(self.symbolConfig)
                }
            }
            .store(in: &cancellables)

        // Привязываем обложку и градиент
        viewModel.$artwork
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                
                // Исправление 2: Добавлен обязательный параметр accessibilityDescription
                let defaultImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
                self.artworkView.image = image ?? defaultImage
                
                self.updateGradient(with: image)
            }
            .store(in: &cancellables)
    }

    private func setupBackground() {
        self.wantsLayer = true
        visualEffectView.frame = self.bounds
        visualEffectView.material = .menu
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        addSubview(visualEffectView)

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

    private func setupLayout() {
        // Конфигурация элементов
        artworkView.wantsLayer = true
        artworkView.layer?.cornerRadius = 8
        
        trackLabel.font = .systemFont(ofSize: 13, weight: .bold)
        trackLabel.lineBreakMode = .byTruncatingTail // Обрезать конец, если текст длинный
        trackLabel.usesSingleLineMode = true
        
        artistLabel.font = .systemFont(ofSize: 11)
        artistLabel.textColor = .secondaryLabelColor
        artistLabel.lineBreakMode = .byTruncatingTail
        artistLabel.usesSingleLineMode = true
        
        let prevBtn = NSButton.createSymbol(name: "backward.fill", target: MenuActions.shared, action: #selector(MenuActions.prevTrack), config: symbolConfig)
        let nextBtn = NSButton.createSymbol(name: "forward.fill", target: MenuActions.shared, action: #selector(MenuActions.nextTrack), config: symbolConfig)
        
        playPauseButton.isBordered = false
        playPauseButton.target = MenuActions.shared
        playPauseButton.action = #selector(MenuActions.togglePlayPause)

        // Сборка стеков
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
        mainStack.edgeInsets = NSEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        mainStack.spacing = 12
        mainStack.alignment = .centerY
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 300),
        
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                
            artworkView.widthAnchor.constraint(equalToConstant: 60),
            artworkView.heightAnchor.constraint(equalToConstant: 60),
                
            info.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -14)
        ])
    }

    private func updateGradient(with image: NSImage?) {
        let colors = image?.extractColors() ?? [NSColor.clear.cgColor, NSColor.clear.cgColor]
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.2)
        gradientLayer.colors = colors
        CATransaction.commit()
    }
}
