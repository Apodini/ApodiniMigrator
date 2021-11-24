//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public class Directory: LibraryComposite {
    public let path: [NameComponent]

    public let content: [LibraryComponent]

    // TODO add init for "well known directory names?"
    public init(_ name: NameComponent..., @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        precondition(!name.isEmpty)
        self.path = name
        self.content = content()
    }

    internal init(_ name: [NameComponent], _content: [LibraryComponent]) {
        precondition(!name.isEmpty)
        self.path = name
        self.content = _content
    }

    public func handle(at path: Path, with context: MigrationContext) throws {
        let directoryPath = path + self.path.description(with: context)

        try directoryPath.mkpath() // TODO investiage client situation?
    }
}
