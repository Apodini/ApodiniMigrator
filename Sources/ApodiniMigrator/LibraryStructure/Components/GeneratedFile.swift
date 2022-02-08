//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// A special ``LibraryNode`` which describes a single generated file, simply by supplying
/// a file name an the source code file using ``SourceCodeRenderable``.
public protocol GeneratedFile: LibraryNode, SourceCodeRenderable {
    var fileName: Name { get }
}

extension GeneratedFile {
    // this method is important for testing
    func formattedFile(with context: MigrationContext) -> String {
        var fileContent = self.renderableContent

        for (placeholder, content) in context.placeholderValues {
            fileContent.replaceOccurrencesRespectingIndent(of: placeholder.description, with: content)
        }

        return fileContent.appending("\n")
    }
}

public extension GeneratedFile {
    /// Default implementation to write the generated file and handle ``Placeholder`` replacements.
    func handle(at path: Path, with context: MigrationContext) throws {
        precondition(!fileName.isEmpty)
        context.logger.info("Rendering file \(fileName.description(with: context)) at: \(path.abbreviate())")
        let filePath = path + fileName.description(with: context)
        try filePath.write(formattedFile(with: context), encoding: .utf8)
    }
}
