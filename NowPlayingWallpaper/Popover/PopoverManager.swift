import Cocoa

final class PopoverManager: NSObject {
    static let shared = PopoverManager()
    
    private let popover = NSPopover()
    private let menuBuilder = MenuBuilder()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private override init() {
        super.init()
        setupStatusItem()
        setupPopover()
    }
    
    private func setupPopover() {
        popover.contentViewController = MenuPlayerViewController()
        popover.behavior = .transient
        popover.animates = true
    }
    
    private func setupStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Now Playing")
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }
    
    @objc private func togglePopover(_ sender: NSButton) {
        guard let button = statusItem.button else { return }
        guard let event = NSApp.currentEvent else { return }
        
        switch event.type {
        case .rightMouseUp:
            let menu = menuBuilder.build()
            menu.popUp(
                positioning: nil,
                at: event.locationInWindow,
                in: sender
            )
            
        case .leftMouseUp:
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(
                    relativeTo: button.bounds,
                    of: button,
                    preferredEdge: .minY
                )
                popover.contentViewController?.view.window?.makeKey()
            }
        default:
            break
        }
    
    }
}
