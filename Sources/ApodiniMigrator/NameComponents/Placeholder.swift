//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A `Placeholder` is a way of deferring the insertion of string content to a later point in time,
/// as this information may not yet be present or accessible.
/// E.g. this is commonly used to use the Swift package name in e.g. directory names or inside source code files.
public struct Placeholder: CustomStringConvertible {
    /// The placeholder formatted string.
    public var description: String {
        "___\(name)___"
    }

    /// The placeholder name.
    public var name: String

    /// Create a new ``Placeholder`` given a placeholder name.
    public init(_ name: String) {
        self.name = name
    }
}

extension Placeholder: Equatable {}

extension Placeholder: Hashable {}
