//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

/// Distinct file / object types
public enum Kind: String {
    case `struct`
    case `class`
    case `enum`
    case `extension`

    /// Signature of `self`, classes are marked with `final` keyword
    public var signature: String {
        "public \(self == .class ? "final " : "")\(rawValue)"
    }
}
