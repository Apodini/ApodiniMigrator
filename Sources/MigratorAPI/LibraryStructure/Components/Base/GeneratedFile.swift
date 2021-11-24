//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public protocol GeneratedFile: LibraryNode {
    var fileName: [NameComponent] { get }

    @FileCodeStringBuilder
    var fileContent: String { get }
}

public extension GeneratedFile {
    func handle(at path: Path, with context: MigrationContext) throws {
        precondition(!fileName.isEmpty)
        let filePath = path + fileName.description(with: context)
        try filePath.write(fileContent, encoding: .utf8)
    }
}


@available(*, deprecated, message: "This protocol was replaced with `GeneratedFile`")
public protocol LegacyGeneratedFile: LibraryNode {
    var fileName: [NameComponent] { get }

    func render(with context: MigrationContext) -> String
}

public extension LegacyGeneratedFile {
    func handle(at path: Path, with context: MigrationContext) throws {
        precondition(!fileName.isEmpty)
        let filePath = path + fileName.description(with: context)
        try filePath.write(render(with: context), encoding: .utf8)
    }
}
