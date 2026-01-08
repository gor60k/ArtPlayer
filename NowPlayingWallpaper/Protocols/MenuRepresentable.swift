import Foundation

protocol MenuRepresentable {
    var title: String { get }
    var action: Selector { get }
    var keyEquivalent: String { get }
    var tag: Int { get }
    var url: URL? { get }
}

extension MenuRepresentable {
    var keyEquivalent: String { "" }
    var tag: Int { 0 }
    var url: URL? { nil }
}

