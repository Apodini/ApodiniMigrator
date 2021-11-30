//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public protocol LibraryComposite: LibraryComponent {
    // TODO doucment this is optional? (LibraryCOmposite may be used as a "DirectoryProtocol" using this thingy!
    var path: [NameComponent] { get }

    @DefaultLibraryComponentBuilder
    var content: [LibraryComponent] { get }

    func handle(at path: Path, with context: MigrationContext) throws
}

public extension LibraryComposite {
    var path: [NameComponent] {
        []
    }

    func handle(at path: Path, with context: MigrationContext) throws {}
}

public extension LibraryComposite {
    // swiftlint:disable:next identifier_name
    func _handle(at path: Path, with context: MigrationContext) throws {
        try handle(at: path, with: context)

        let nextPath = self.path.isEmpty
            ? path
            : path + self.path.description(with: context)

        for component in content {
            try component._handle(at: nextPath, with: context)
        }
    }
}
