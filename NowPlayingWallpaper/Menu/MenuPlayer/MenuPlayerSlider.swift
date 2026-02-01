import Cocoa
import Combine

final class MenuPlayerSlider: NSSlider {
    private var isUserInteraction: Bool = false
    private let menuActions = MenuActions()
    private let viewModel = MenuPlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()

    
    private let currentPosition = NSTextField(labelWithString: "0:00")
    private let totalDuration = NSTextField(labelWithString: "0:00")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }
    
    private func setupSlider() {
        isContinuous = true
        minValue = 0
        maxValue = 1
        
        controlSize = .small
        
        currentPosition.font = .systemFont(ofSize: 10)
        currentPosition.textColor = .secondaryLabelColor
        currentPosition.alignment = .left
        currentPosition.translatesAutoresizingMaskIntoConstraints = false
        
        totalDuration.font = .systemFont(ofSize: 10)
        totalDuration.textColor = .secondaryLabelColor
        totalDuration.alignment = .right
        totalDuration.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(currentPosition)
        addSubview(totalDuration)
        
        NSLayoutConstraint.activate([
            currentPosition.leadingAnchor.constraint(equalTo: leadingAnchor),
            currentPosition.topAnchor.constraint(equalTo: bottomAnchor, constant: 2),
            
            totalDuration.trailingAnchor.constraint(equalTo: trailingAnchor),
            totalDuration.topAnchor.constraint(equalTo: bottomAnchor, constant: 2)
        ])

        target = self
        action = #selector(sliderValueChanged(_:))
    }
    
    override func mouseDown(with event: NSEvent) {
        isUserInteraction = true
        super.mouseDown(with: event)
        isUserInteraction = false
    }
    
    @objc func sliderValueChanged(_ sender: NSSlider) {}
    
    func update (position: String, duration: String) {
        currentPosition.stringValue = position
        totalDuration.stringValue = duration
    }
}
