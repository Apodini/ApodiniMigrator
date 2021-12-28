//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

public class Directory: LibraryComposite {
    public let path: Name

    public let content: [LibraryComponent]

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

        try directoryPath.mkpath()
    }
}
