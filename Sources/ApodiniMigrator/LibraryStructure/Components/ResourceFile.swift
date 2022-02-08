//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// A `ResourceFile` is a file which is copied from the resources (e.g. `Bundle.module`) of a target.
/// The file is searched in the bundle supplied in the ``Migrator``.
public class ResourceFile: LibraryNode {
    let srcFileName: Name
    let dstFilename: Name

    /// String which is to be prepended to the resulting file. Empty if not supplied.
    let filePrefix: String
    /// String which is to be appended to the resulting file. Empty if not supplied.
    let fileSuffix: String

    var contentReplacer: [Placeholder: String] = [:]

    /// Initializes a new `ResourceFile`.
    /// - Parameters:
    ///   - srcFileName: The file ``Name`` to search for in the ``Migrator/bundle``.
    ///   - dstFileName: If supplied the filename is used when writing the file to disk.
    ///         Otherwise the `srcFileName` is used.
    ///   - filePrefix: Optional ``SourceCodeBuilder`` closure to supply a prefix which is prepended to the file content.
    ///   - fileSuffix: Optional ``SourceCodeBuilder`` closure to supply a suffix which is appended to the file content.
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

    /// Adds a new content replacement for the given file. This can be used to dynamically supply ``Placeholder`` values.
    /// - Parameters:
    ///   - placeholder: The ``Placeholder`` which should be replaced in the file content.
    ///   - content: The value for the ``Placeholder``.
    /// - Returns: Returns `self` for chanining.
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
            fileContent.replaceOccurrencesRespectingIndent(of: placeholder.description, with: content)
        }

        if !filePrefix.isEmpty {
            fileContent = filePrefix + "\n" + fileContent
        }
        if !fileSuffix.isEmpty {
            fileContent += "\n" + fileSuffix
        }

        context.logger.info("Copying resource file \(rawSrcFileName)\(rawSrcFileName != rawDstFileName ? "to \(rawDstFileName)": "") at: \(path.abbreviate())")

        let destinationPath = path + rawDstFileName
        try destinationPath.write(fileContent, encoding: .utf8)
    }
}

extension ResourceFile: CustomStringConvertible {
    public var description: String {
        "ResourceFile(fileName: \(srcFileName))"
    }
}
