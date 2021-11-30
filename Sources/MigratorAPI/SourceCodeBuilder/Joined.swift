//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

public struct Joined: SourceCodeComponent {
    public enum JoinType {
        case appendPreviousLine
        case prependNextLine
    }

    private let separator: String
    private let joinType: JoinType
    private let content: [SourceCodeComponent]

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
