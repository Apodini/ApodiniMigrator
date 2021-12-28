//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

public class ResourceFile: LibraryNode {
    let srcFileName: Name
    let dstFilename: Name

    /// String which is to be prepended to the resulting file. Empty if not supplied.
    let filePrefix: String
    /// String which is to be appended to the resulting file. Empty if not supplied.
    let fileSuffix: String

    var contentReplacer: [Placeholder: String] = [:]

    public init(
        copy srcFileName: Name,
        to dstFileName: Name? = nil,
        @SourceCodeBuilder filePrefix: () -> String = { "" },
        @SourceCodeBuilder fileSuffix: () -> String = { "" }
    ) {
        precondition(!srcFileName.isEmpty)
        self.srcFileName = srcFileName
        if let dstFileName = dstFileName {
            self.dstFilename = dstFileName
        } else {
            self.dstFilename = srcFileName
        }
        self.filePrefix = filePrefix()
        self.fileSuffix = fileSuffix()
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
            // this block is basically a `fileContent.replacingOccurrences(of: placeholder.description, with: content)`
            //  though it considers the indent of a `placeholder` and applies it to the lines of `content`
            while let range = fileContent.range(of: placeholder.description) {
                let indent = indent(of: fileContent, at: range)
                let indentedContent = content
                    .split(separator: "\n", omittingEmptySubsequences: false)
                    .joined(separator: "\n\(indent)")

                fileContent.replaceSubrange(range, with: indentedContent)
            }
        }

        if !filePrefix.isEmpty {
            fileContent = filePrefix + "\n" + fileContent
        }
        if !fileSuffix.isEmpty {
            fileContent += "\n" + fileSuffix
        }

        let destinationPath = path + rawDstFileName
        try destinationPath.write(fileContent, encoding: .utf8)
    }

    private func indent(of content: String, at range: Range<String.Index>) -> String {
        var index = content.index(before: range.lowerBound)

        var indent = ""

        while content[index] == " " {
            index = content.index(before: index)
            indent += " "
        }

        if content[index] == "\n" {
            return indent
        }

        return ""
    }
}

extension ResourceFile: CustomStringConvertible {
    public var description: String {
        "ResourceFile(fileName: \(srcFileName))"
    }
}
