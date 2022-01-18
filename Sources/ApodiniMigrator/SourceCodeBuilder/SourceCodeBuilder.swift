//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

// the protocols are to workaround inheritance and at the same time use enum
// type to host static-only members for efficiency.

@resultBuilder
public enum SourceCodeBuilder: SourceCodeBuilderProtocol {}

@resultBuilder
public enum SourceCodeComponentBuilder: SourceCodeComponentBuilderProtocol {}


/// The ``SourecCodeBuilder`` protocol.
public protocol SourceCodeComponentBuilderProtocol {}

extension SourceCodeComponentBuilderProtocol {
    /// Build ``SourceCodeComponent``s from a `CustomStringConvertible` expression.
    @_disfavoredOverload
    public static func buildExpression<Convertible: CustomStringConvertible>(_ expression: Convertible) -> [SourceCodeComponent] {
        [expression.description]
    }

    /// Build a ``SourceCodeComponent`` expression.
    public static func buildExpression<Renderable: SourceCodeComponent>(_ expression: Renderable) -> [SourceCodeComponent] {
        [expression]
    }

    /// Build an array of ``SourceCodeComponent``s.
    public static func buildExpression<Renderable: SourceCodeComponent>(_ expression: [Renderable]) -> [SourceCodeComponent] {
        expression
    }

    /// Builds a `Void` expression. This can be used to e.g. allow for property declarations inside
    /// of the resultBuilder closure.
    public static func buildExpression(_ expression: Void) -> [SourceCodeComponent] {
        []
    }

    /// Builds a `Never` expression.
    /// This overload allows to place e.g. method calls which will never return (e.g. like `fatalError`).
    public static func buildExpression(_ expression: Never) -> [SourceCodeComponent] {
        // will never be executed
    }

    /// Build the block of ``SourceCodeComponent``s.
    public static func buildBlock(_ components: [SourceCodeComponent]...) -> [SourceCodeComponent] {
        components.flatten()
    }

    /// Build either first.
    public static func buildEither(first component: [SourceCodeComponent]) -> [SourceCodeComponent] {
        [Group(content: component)]
    }

    /// Build either second.
    public static func buildEither(second component: [SourceCodeComponent]) -> [SourceCodeComponent] {
        [Group(content: component)]
    }

    /// Build an optional expression.
    public static func buildOptional(_ component: [SourceCodeComponent]?) -> [SourceCodeComponent] {
        // swiftlint:disable:previous discouraged_optional_collection
        guard let component = component else {
            return []
        }
        return [Group(content: component)]
    }

    /// Build an array (for loops).
    public static func buildArray(_ components: [[SourceCodeComponent]]) -> [SourceCodeComponent] {
        [Group(content: components.flatten())]
    }
}

public protocol SourceCodeBuilderProtocol: SourceCodeComponentBuilderProtocol {}

extension SourceCodeBuilderProtocol {
    /// Build the final source code file content.
    /// This will render all the ``SourceCodeComponent``s and join them by the line separator `\n`.
    public static func buildFinalResult(_ component: [SourceCodeComponent]) -> String {
        component
            .map { $0.render() }
            .flatten()
            .joined(separator: "\n")
    }
}
