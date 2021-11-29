//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

// TODO rename to SourceCodeBuilder?

public protocol FileCodeRenderable {
    func render() -> [String]
}

extension String: FileCodeRenderable {
    /// Every String is interpreted as a single line in the resulting code file.
    /// Therefore the render method always appends a line separator symbol.
    public func render() -> [String] {
        self
            .split(separator: "\n", omittingEmptySubsequences: false) // TODO is this needed?
            .map { String($0) }
    }
}

public struct Indent: FileCodeRenderable {
    private let identString: String
    private let content: [FileCodeRenderable]

    public init(
        with identString: String = "    ",
        @FileCodeBuilder content: () -> [FileCodeRenderable]
    ) {
        self.identString = identString
        self.content = content()
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
            .map { identString + $0 }
    }
}

// TODO split out stuff from file
public struct Joined: FileCodeRenderable {
    public enum JoinType {
        case appendPreviousLine
        case prependNextLine
    }

    private let separator: String
    private let joinType: JoinType
    private let content: [FileCodeRenderable]

    public init(
        by separator: String,
        using joinType: JoinType = .appendPreviousLine,
        @FileCodeBuilder content: () -> [FileCodeRenderable]
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

public struct Group: FileCodeRenderable { // TODO document, only really useful in combination with the Joined operator!
    private let content: [FileCodeRenderable]

    public init(@FileCodeBuilder content: () -> [FileCodeRenderable]) {
        self.content = content()
    }

    fileprivate init(content: [FileCodeRenderable]) {
        self.content = content
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
    }
}

@resultBuilder
public class FileCodeBuilder {
    // TODO add expression for the Renderable protocol?
    @_disfavoredOverload
    public static func buildExpression<Convertible: CustomStringConvertible>(_ expression: Convertible) -> [FileCodeRenderable] {
        [expression.description]
    }

    public static func buildExpression<Renderable: FileCodeRenderable>(_ expression: Renderable) -> [FileCodeRenderable] {
        [expression]
    }

    public static func buildExpression<Renderable: FileCodeRenderable>(_ expression: [Renderable]) -> [FileCodeRenderable] {
        expression // TODO Group those?
    }

    public static func buildExpression(_ expression: Void) -> [FileCodeRenderable] {
        []
    }

    public static func buildBlock(_ components: [FileCodeRenderable]...) -> [FileCodeRenderable] {
        components.flatten()
    }

    public static func buildEither(first component: [FileCodeRenderable]) -> [FileCodeRenderable] {
        [Group(content: component)]
    }

    public static func buildEither(second component: [FileCodeRenderable]) -> [FileCodeRenderable] {
        [Group(content: component)]
    }

    public static func buildOptional(_ component: [FileCodeRenderable]?) -> [FileCodeRenderable] {
        guard let component = component else {
            return []
        }
        return [Group(content: component)]
    }

    public static func buildArray(_ components: [[FileCodeRenderable]]) -> [FileCodeRenderable] {
        [Group(content: components.flatten())]
    }
}

@resultBuilder
public class FileCodeStringBuilder: FileCodeBuilder {
    public static func buildFinalResult(_ component: [FileCodeRenderable]) -> String {
        component
            .map { $0.render() }
            .flatten()
            .joined(separator: "\n")
    }
}
