import Cocoa

final class MenuPlayerInfoStackView: NSStackView {
    let trackLabel: NSTextField
    let artistLabel: NSTextField
    
    init() {
        self.trackLabel = NSTextField.createTrackLabel()
        self.artistLabel = NSTextField.createArtistLabel()
        
        self.trackLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.artistLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                
        self.trackLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.artistLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        super.init(frame: .zero)
        
        [trackLabel, artistLabel].forEach { addArrangedSubview($0) }
        orientation = .vertical
        alignment = .leading
        spacing = 2
        
        translatesAutoresizingMaskIntoConstraints = false

    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func update(title: String, artist: String) {
        trackLabel.stringValue = title
        artistLabel.stringValue = artist
    }
}

