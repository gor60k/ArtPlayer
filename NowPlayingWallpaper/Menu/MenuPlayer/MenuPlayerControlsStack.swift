import Cocoa

final class MenuPlayerControlsStack: NSStackView {
    let prevBtn: NSButton
    let playPauseBtn: NSButton
    let nextBtn: NSButton

    init(target: Any?, config: NSImage.SymbolConfiguration) {
        self.prevBtn = NSButton.createSymbol(name: "backward.fill", target: target, action: #selector(MenuActions.prevTrack), config: config)
        self.playPauseBtn = NSButton.createSymbol(name: "play.fill", target: target, action: #selector(MenuActions.togglePlayPause), config: config)
        self.nextBtn = NSButton.createSymbol(name: "forward.fill", target: target, action: #selector(MenuActions.nextTrack), config: config)
        
        super.init(frame: .zero)
        
        [prevBtn, playPauseBtn, nextBtn].forEach { addArrangedSubview($0) }
        spacing = 15
        
        NSLayoutConstraint.activate([
            prevBtn.widthAnchor.constraint(equalToConstant: 24),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 24),
            nextBtn.widthAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
