//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public class ResourceFile: LibraryNode {
    let srcFileName: [NameComponent]
    let dstFilename: [NameComponent]

    var contentReplacer: [Placeholder: String] = [:]

    public init(copy srcFileName: NameComponent..., to dstFileName: NameComponent...) {
        precondition(!srcFileName.isEmpty)
        self.srcFileName = srcFileName
        self.dstFilename = dstFileName.isEmpty ? srcFileName : dstFileName
    }

    public func replacing(_ placeholder: Placeholder, with content: String) -> Self {
        precondition(contentReplacer[placeholder] == nil)
        contentReplacer[placeholder] = content
        return self
    }

    public func handle(at path: Path, with context: MigrationContext) throws {
        let rawSrcFileName = srcFileName.description(with: context)
        let rawDstFileName = dstFilename.description(with: context)

        guard let fileUrl = context.bundle.url(forResource: rawSrcFileName, withExtension: nil) else {
            fatalError("Could not locate resource (\(rawSrcFileName)) in bundle (\(context.bundle)) for \(self)")
        }

        guard var fileContent = try? String(contentsOf: fileUrl, encoding: .utf8) else {
            fatalError("Failed to read file contents (\(rawSrcFileName)) in bundle (\(context.bundle) for \(self)")
        }

        for (placeholder, content) in context.placeholderValues.merging(contentReplacer, uniquingKeysWith: { $1 }) {
            // TODO save ident for multiline replacements! (for code files only?)
            fileContent = fileContent.replacingOccurrences(of: placeholder.description, with: content)
        }

        let destinationPath = path + rawDstFileName
        try destinationPath.write(fileContent, encoding: .utf8)
    }
}

extension ResourceFile: CustomStringConvertible {
    public var description: String {
        "ResourceFile(fileName: \(srcFileName))"
    }
}
