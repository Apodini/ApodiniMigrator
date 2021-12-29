//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A simple string based file.
public struct StringFile: GeneratedFile {
    /// The file ``Name``.
    public let fileName: Name
    /// The file content encoded as a string.
    public let renderableContent: String

    /// Initialize a new `StringFile` by supplying file name and the content by string.
    /// - Parameters:
    ///   - fileName: The file ``Name``.
    ///   - content: The full file content encoded as a string.
    public init(name fileName: Name, content: String) {
        self.fileName = fileName
        self.renderableContent = content
    }

    /// Initialize a new `StringFile` by supplying file name and the content using the ``SourceCodeBuilder``.
    /// - Parameters:
    ///   - fileName: The file ``Name``.
    ///   - content: The content provided as a ``SourceCodeBuilder`` closure.
    public init(name fileName: Name, @SourceCodeBuilder content: () -> String) {
        self.fileName = fileName
        self.renderableContent = content()
    }
}
