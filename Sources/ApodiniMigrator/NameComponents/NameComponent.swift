//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A `NameComponent` is a single component of a ``Name``.
/// It is typically a `String` literal or a ``Placeholder`` value.
public protocol NameComponent: CustomStringConvertible {
    /// Retrieve the string representation of the ``NameComponent`` given the ``MigrationContext``.
    /// - Parameter context: The ``MigrationContext`` which is used to retrieve values for a ``Placeholder``.
    /// - Returns: The `String` with any ``Placeholder``s replaced (if they are present in the context).
    func description(with context: MigrationContext) -> String
}
