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
        expression
    }

    public static func buildExpression(_ expression: Void) -> [FileCodeRenderable] {
        []
    }

    public static func buildBlock(_ components: [FileCodeRenderable]...) -> [FileCodeRenderable] {
        components.flatten()
    }

    public static func buildEither(first component: [FileCodeRenderable]) -> [FileCodeRenderable] {
        component
    }

    public static func buildEither(second component: [FileCodeRenderable]) -> [FileCodeRenderable] {
        component
    }

    public static func buildOptional(_ component: [FileCodeRenderable]?) -> [FileCodeRenderable] {
        component ?? []
    }

    public static func buildArray(_ components: [[FileCodeRenderable]]) -> [FileCodeRenderable] {
        components.flatten()
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
