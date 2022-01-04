//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// A ``LibraryComposite`` used to build a `Directory`.
/// The `Directory` might container other ``LibraryComponent``s.
public class Directory: LibraryComposite {
    /// The directory name
    public let path: Name

    /// The directory content.
    public let content: [LibraryComponent]

    /// Create a new `Directory`.
    /// - Parameters:
    ///   - name: The directory name.
    ///   - content: The directory content using a ``DefaultLibraryComponentBuilder`` closure.
    public init(_ name: Name, @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        precondition(!name.isEmpty)
        self.path = name
        self.content = content()
    }

    // swiftlint:disable:next identifier_name
    internal init(_ name: Name, _content: [LibraryComponent]) {
        precondition(!name.isEmpty)
        self.path = name
        self.content = _content
    }

    public func handle(at path: Path, with context: MigrationContext) throws {
        let directoryPath = path + self.path.description(with: context)

        context.logger.debug("Creating directory \(self.path.description(with: context)) at: \(path.absolute())")
        try directoryPath.mkpath()
    }
}
