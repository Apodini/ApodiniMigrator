//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
