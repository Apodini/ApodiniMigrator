//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// A `LibraryComponent` describes any sort of component of a library structure.
/// This is the base protocol implementing a composite pattern.
///
/// - SeeAlso: ``LibraryNode`` and ``LibraryComposite``.
public protocol LibraryComponent {
    /// The base `handle` method to handle a ``LibraryComponent``.
    /// This method is implemented by default by e.g. ``LibraryNode`` or ``LibraryComposite``.
    ///
    /// - Parameters:
    ///   - path: The path where this component is placed under.
    ///   - context: The ``MigrationContext`` in which this component is called.
    /// - Throws: Throws any potential errors by the implementing parties.
    func _handle(at path: Path, with context: MigrationContext) throws // swiftlint:disable:this identifier_name
}
