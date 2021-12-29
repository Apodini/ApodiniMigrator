//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Join several ``SourceCodeComponent``
public struct Joined: SourceCodeComponent {
    /// Describes how the ``SourceCodeComponent``s are joined.
    /// This basically controls if the separator is applied before or after the newline character.
    public enum JoinType {
        case appendPreviousLine
        case prependNextLine
    }

    private let separator: String
    private let joinType: JoinType
    private let content: [SourceCodeComponent]

    /// Initialize new joined ``SourceCodeComponent``s.
    /// - Parameters:
    ///   - separator: The separator character.
    ///   - joinType: Optionally, the ``JoinType``.
    ///   - content: The content of ``SourceCodeComponents``.
    ///     Note: You might want to use ``Group`` to group several ``SourceCodeComponents`` such that they are treated as
    ///     a single component here.
    public init(
        by separator: String,
        using joinType: JoinType = .appendPreviousLine,
        @SourceCodeComponentBuilder content: () -> [SourceCodeComponent]
    ) {
        self.separator = separator
        self.joinType = joinType
        self.content = content()
    }

    public func render() -> [String] {
        var lines = content
            .map { $0.render() }
            .filter { !$0.isEmpty }

        switch joinType {
        case .appendPreviousLine:
            for index in lines.startIndex ..< lines.index(before: lines.endIndex) {
                let groupedLines = lines[index]
                precondition(!groupedLines.isEmpty)
                let groupIndex = groupedLines.index(before: groupedLines.endIndex)

                lines[index][groupIndex] = groupedLines[groupIndex] + separator
            }
        case .prependNextLine:
            for index in lines.index(after: lines.startIndex) ..< lines.endIndex {
                let groupedLines = lines[index]
                precondition(!groupedLines.isEmpty)
                let groupIndex = groupedLines.startIndex

                lines[index][groupIndex] = separator + groupedLines[groupIndex]
            }
        }

        return lines
            .flatten()
    }
}
