import Foundation

/// A protocol for types that render a string content
protocol Renderable {
    /// A functions that returns the string content of a `Renderable` instance
    func render() -> String
}
