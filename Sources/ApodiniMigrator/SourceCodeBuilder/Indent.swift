//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Creates an indented section in the ``SourceCodeBuilder``.
public struct Indent: SourceCodeComponent {
    private let indentString: String
    private let content: [SourceCodeComponent]

    /// Creates a new indented content.
    /// - Parameters:
    ///   - indentString: The indent string.
    ///   - content: The content as string.
    public init(with indentString: String = "    ", _ content: String) {
        self.indentString = indentString
        self.content = [content]
    }

    /// Creates a new indented ``SourceCodeComponent``s build via a ``SourceCodeComponentBuilder`` closure.
    /// - Parameters:
    ///   - indentString: The indent string.
    ///   - content: The content which is indented provided by a result builder closure.
    public init(
        with indentString: String = "    ",
        @SourceCodeComponentBuilder content: () -> [SourceCodeComponent]
    ) {
        self.indentString = indentString
        self.content = content()
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
            .map { indentString + $0 }
    }
}
