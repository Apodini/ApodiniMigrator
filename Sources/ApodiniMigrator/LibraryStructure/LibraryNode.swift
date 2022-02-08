//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// Describes a single leaf node in the tree of ``LibraryComponent``.
/// This is the leaf of the composite pattern.
public protocol LibraryNode: LibraryComponent {
    /// The `handle` method is called to handle the ``LibraryNode``.
    ///
    /// - Parameters:
    ///   - path: The path where this component is placed under.
    ///   - context: The ``MigrationContext`` in which this component is called.
    /// - Throws: Throws any potential errors by the implementing parties.
    func handle(at path: Path, with context: MigrationContext) throws
}

public extension LibraryNode {
    /// Default implementation forwarding call.
    func _handle(at path: Path, with context: MigrationContext) throws { // swiftlint:disable:this identifier_name
        try handle(at: path, with: context)
    }
}
