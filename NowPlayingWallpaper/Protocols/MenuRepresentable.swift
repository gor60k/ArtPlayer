import Foundation

protocol MenuRepresentable {
    var title: String { get }
    var action: Selector { get }
    var keyEquivalent: String { get }
    var tag: Int { get }
}

// Стандартные реализации, чтобы не переписывать их в каждом Enum
extension MenuRepresentable {
    var keyEquivalent: String { "" }
    var tag: Int { 0 }
}

