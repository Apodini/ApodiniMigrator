import Foundation

/// An object representing a spacer / indentation in a swift file
struct Indentation: CustomStringConvertible {
    /// A space string with length of 4
    static let tab = String(repeating: " ", count: 4)

    /// The level of the indentation
    private var level: UInt
    
    /// Complete space of this indentation, repeating `Indentation.tab` `level`-times
    var description: String {
        String(repeating: Self.tab, count: Int(level))
    }
    
    // MARK: - Initializer
    init(_ level: UInt) {
        self.level = level
    }
    
    
    /// Decreases level by one
    mutating func dropLevel() {
        level = max(0, level - 1)
    }
    
    /// Adds indentation to `rhs`
    static func + (lhs: Self, rhs: String) -> String {
        lhs.description + rhs
    }
}
