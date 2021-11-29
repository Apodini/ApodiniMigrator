//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

// TODO move
public protocol RenderableBuilder: FileCodeRenderable {
    @FileCodeStringBuilder
    var fileContent: String { get } // TODO nameing?
}

public extension RenderableBuilder {
    func render() -> [String] {
        fileContent
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }
    }
}

public protocol GeneratedFile: LibraryNode, RenderableBuilder {
    var fileName: [NameComponent] { get }
}

extension GeneratedFile {
    // this method is important for testing
    func formattedFile(with context: MigrationContext) -> String {
        var fileContent = self.fileContent

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
