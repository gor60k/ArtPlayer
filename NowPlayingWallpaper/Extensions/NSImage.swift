import AppKit

extension NSImage {
    func extractColors() -> [CGColor] {
        
        let smallSize = NSSize(width: 40, height: 40)
        let smallImage = NSImage(size: smallSize)
        
        smallImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: smallSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        smallImage.unlockFocus()
        
        guard let tiff = smallImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else {
            return [NSColor.clear.cgColor, NSColor.clear.cgColor]
        }
        
        let color1 = bitmap.colorAt(x: 5, y: 5)?.withAlphaComponent(0.4) ?? .clear
        let color2 = bitmap.colorAt(x: 35, y: 35)?.withAlphaComponent(0.3) ?? .clear
        
        return [color1.cgColor, color2.cgColor]
    }
}
