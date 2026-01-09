import Cocoa

final class MenuPlayerBackgroundView: NSView {
    private let gradientLayer = CAGradientLayer()
    private let visualEffectView = NSVisualEffectView()
    private let gradientContainer = NSView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
            
        visualEffectView.material = .menu
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)

        gradientContainer.wantsLayer = true
        gradientContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientContainer)
            
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.opacity = 0.6
        gradientContainer.layer?.addSublayer(gradientLayer)

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            gradientContainer.topAnchor.constraint(equalTo: topAnchor),
            gradientContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layout() {
        super.layout()
        gradientLayer.frame = gradientContainer.bounds
    }

    func updateGradient(with colors: [CGColor]) {
        guard !colors.isEmpty else { return }
        
        let finalColors = colors.count == 1 ? [colors[0], colors[0]] : colors
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.2)
        gradientLayer.colors = colors
        CATransaction.commit()
    }
}

