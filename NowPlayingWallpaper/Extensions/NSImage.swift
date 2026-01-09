import AppKit

extension NSImage {
    var jpegData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmap  = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
    }
    
    func extractColors() -> [CGColor] {
        guard let tiff = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else {
            return [NSColor.clear.cgColor, NSColor.clear.cgColor]
        }
        
        let with = bitmap.pixelsWide
        let height = bitmap.pixelsHigh
        
        let color1 = bitmap.colorAt(x: with / 8, y: height / 8)?
            .withAlphaComponent(0.4) ?? .black
        let color2 = bitmap.colorAt(x: with * 7 / 8, y: height * 7 / 8)?
            .withAlphaComponent(0.3) ?? .black
        
        return [color1.cgColor, color2.cgColor]
    }
}
