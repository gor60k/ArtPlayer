import Cocoa
import Combine

final class MenuController: NSObject, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var playerView: MenuPlayer = MenuPlayer()
    
    override init() {
        super.init()
        setupObserver()
    }
    
    private func setupObserver() {
        let artworkRedraw = MenuPlayerViewModel.shared.$artwork.map { _ in () }
        let titleRedraw = MenuPlayerViewModel.shared.$trackTitle.map { _ in () }
        
        artworkRedraw
            .merge(with: titleRedraw)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.statusItem.menu?.update()
            }
            .store(in: &cancellables)
    }
}
