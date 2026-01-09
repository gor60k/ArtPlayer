import Cocoa

final class MenuPlayerControlsStack: NSStackView {
    let prevBtn: NSButton
    let playPauseBtn: NSButton
    let nextBtn: NSButton

    init(target: Any?, playConfig: NSImage.SymbolConfiguration, buttonConfig: NSImage.SymbolConfiguration) {
        self.prevBtn = NSButton.createSymbol(name: "backward.fill", target: target, action: #selector(MenuActions.prevTrack), config: buttonConfig)
        self.playPauseBtn = NSButton.createSymbol(name: "play.fill", target: target, action: #selector(MenuActions.togglePlayPause), config: playConfig)
        self.nextBtn = NSButton.createSymbol(name: "forward.fill", target: target, action: #selector(MenuActions.nextTrack), config: buttonConfig)
        
        super.init(frame: .zero)
        
        [prevBtn, playPauseBtn, nextBtn].forEach { addArrangedSubview($0) }
        spacing = 20
        alignment = .centerY
        
        NSLayoutConstraint.activate([
            prevBtn.widthAnchor.constraint(equalToConstant: 24),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 32),
            nextBtn.widthAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
