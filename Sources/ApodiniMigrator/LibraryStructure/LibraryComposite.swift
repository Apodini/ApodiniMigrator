//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// The composition of ``LibraryComponent``s.
/// This realizes the composite pattern.
public protocol LibraryComposite: LibraryComponent {
    /// An optional protocol requirement. By default this is empty.
    /// If supplied the `LibraryComposite` will be treated as a directory and all of the
    /// ``content`` components are placed under the supplied directory ``Name``.
    var path: Name { get }

    /// The content of the ``LibraryComposite`` buildt using ``DefaultLibraryComponentBuilder``.
    @DefaultLibraryComponentBuilder
    var content: [LibraryComponent] { get }

    /// Optionally to implement, called when this ``LibraryComponent`` is handled.
    /// - Parameters:
    ///   - path: The path this component is placed under (doesn't include ``LibraryComposite/path``).
    ///   - context: The ``MigrationContext`` with which this component is called
    /// - Throws: May throw any sort of error occuring when hanlding this component.
    func handle(at path: Path, with context: MigrationContext) throws
}

public extension LibraryComposite {
    /// Default implementation with an empty name.
    var path: Name {
        Name(empty: ())
    }

    /// Default implementation for handle, which does nothing.
    func handle(at path: Path, with context: MigrationContext) throws {
        context.logger.info("Handling library composite \(Self.self) at: \(path.abbreviate())")
    }
}

public extension LibraryComposite {
    /// Default implementation for the internal `_handle` call.
    /// This will call `handle` for self and all of the content ``LibraryComponent``s.
    /// It automatically handles non empty ``LibraryComposite/path`s.
    func _handle(at path: Path, with context: MigrationContext) throws {
        // swiftlint:disable:previous identifier_name
        try handle(at: path, with: context)

        let nextPath = self.path.isEmpty
            ? path
            : path + self.path.description(with: context)

        for component in content {
            try component._handle(at: nextPath, with: context)
        }
    }
}
