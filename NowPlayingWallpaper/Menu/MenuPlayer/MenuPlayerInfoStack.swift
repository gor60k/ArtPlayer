import Cocoa

final class MenuPlayerInfoStackView: NSStackView {
    let trackLabel: NSTextField
    let artistLabel: NSTextField
    
    init() {
        self.trackLabel = NSTextField.createTrackLabel()
        self.artistLabel = NSTextField.createArtistLabel()
        
        super.init(frame: .zero)
        
        [trackLabel, artistLabel].forEach { addArrangedSubview($0) }
        orientation = .vertical
        alignment = .left
        distribution = .gravityAreas
        spacing = 2
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func update(title: String, artist: String) {
        trackLabel.stringValue = title
        artistLabel.stringValue = artist
    }
}

