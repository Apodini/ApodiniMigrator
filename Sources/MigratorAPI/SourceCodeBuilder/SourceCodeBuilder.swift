//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

@resultBuilder
public class SourceCodeBuilder: SourceCodeComponentBuilder {
    public static func buildFinalResult(_ component: [SourceCodeComponent]) -> String {
        component
            .map { $0.render() }
            .flatten()
            .joined(separator: "\n")
    }
}

@resultBuilder
public class SourceCodeComponentBuilder {
    @_disfavoredOverload
    public static func buildExpression<Convertible: CustomStringConvertible>(_ expression: Convertible) -> [SourceCodeComponent] {
        [expression.description]
    }

    public static func buildExpression<Renderable: SourceCodeComponent>(_ expression: Renderable) -> [SourceCodeComponent] {
        [expression]
    }

    public static func buildExpression<Renderable: SourceCodeComponent>(_ expression: [Renderable]) -> [SourceCodeComponent] {
        expression
    }

    public static func buildExpression(_ expression: Void) -> [SourceCodeComponent] {
        []
    }

    public static func buildBlock(_ components: [SourceCodeComponent]...) -> [SourceCodeComponent] {
        components.flatten()
    }

    public static func buildEither(first component: [SourceCodeComponent]) -> [SourceCodeComponent] {
        [Group(content: component)]
    }

    public static func buildEither(second component: [SourceCodeComponent]) -> [SourceCodeComponent] {
        [Group(content: component)]
    }

    // swiftlint:disable:next discouraged_optional_collection
    public static func buildOptional(_ component: [SourceCodeComponent]?) -> [SourceCodeComponent] {
        guard let component = component else {
            return []
        }
        return [Group(content: component)]
    }

    public static func buildArray(_ components: [[SourceCodeComponent]]) -> [SourceCodeComponent] {
        [Group(content: components.flatten())]
    }
}
