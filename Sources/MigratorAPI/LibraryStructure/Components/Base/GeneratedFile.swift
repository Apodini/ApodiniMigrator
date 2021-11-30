//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public protocol GeneratedFile: LibraryNode, SourceCodeRenderable {
    var fileName: [NameComponent] { get }
}

extension GeneratedFile {
    // this method is important for testing
    func formattedFile(with context: MigrationContext) -> String {
        var fileContent = self.renderableContent

        for (placeholder, content) in context.placeholderValues {
            // TODO code duplication to the `ResourceFile`!
            fileContent = fileContent.replacingOccurrences(of: placeholder.description, with: content)
        }

        return fileContent.appending("\n")
    }
}

public extension GeneratedFile {
    func handle(at path: Path, with context: MigrationContext) throws {
        precondition(!fileName.isEmpty)
        let filePath = path + fileName.description(with: context)
        try filePath.write(formattedFile(with: context), encoding: .utf8)
    }
}
