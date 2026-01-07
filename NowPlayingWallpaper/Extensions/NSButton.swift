import AppKit

extension NSButton {
    static func createSymbol(name: String, target: Any?, action: Selector?, config: NSImage.SymbolConfiguration) -> NSButton {
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration(config)
        let btn = NSButton(image: image ?? NSImage(), target: target, action: action)
        btn.isBordered = false
        return btn
    }
}
