//
// Created by Andreas Bauer on 23.11.21.
//

public protocol DirectoryProtocol: LibraryComposite {
    var path: [NameComponent] { get }

    func handle(at path: Path, with context: MigrationContext) throws
}

public extension DirectoryProtocol {
    func _handle(at path: Path, with context: MigrationContext) throws {
        try handle(at: path, with: context)

        let nextPath = path + self.path.description(with: context)

        for component in content {
            try component._handle(at: nextPath, with: context)
        }
    }
}
