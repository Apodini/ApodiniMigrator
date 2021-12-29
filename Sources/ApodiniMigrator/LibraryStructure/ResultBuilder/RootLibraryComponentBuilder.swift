//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The ``LibraryComponent`` builder to build a ``RootDirectory`` of a swift package.
@resultBuilder
public enum RootLibraryComponentBuilder {
    /// Build an expression from a ``Sources`` directory.
    /// - Parameter expression: The ``Sources`` expression.
    /// - Returns: Returns the component.
    public static func buildExpression(_ expression: Sources) -> [LibraryComponent] {
        [expression]
    }

    /// Build an expression from a ``Tests`` directory.
    /// - Parameter expression: The ``Tests`` expression.
    /// - Returns: Returns the component.
    public static func buildExpression(_ expression: Tests) -> [LibraryComponent] {
        [expression]
    }

    /// Build an expression from a ``LibraryNode``.
    /// - Parameter expression: The ``LibraryNode`` expression.
    /// - Returns: Returns the component.
    public static func buildExpression(_ expression: LibraryNode) -> [LibraryComponent] {
        [expression]
    }

    /// Build a block from ``LibraryComponent``s.
    /// - Parameter components: The components
    /// - Returns: Returns the component.
    public static func buildBlock(_ components: [LibraryComponent]...) -> [LibraryComponent] {
        components.flatten()
    }

    /// Build either first.
    public static func buildEither(first component: [LibraryComponent]) -> [LibraryComponent] {
        component
    }

    /// Build either second.
    public static func buildEither(second component: [LibraryComponent]) -> [LibraryComponent] {
        component
    }

    /// Build an optional expression.
    public static func buildOptional(_ component: [LibraryComponent]?) -> [LibraryComponent] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? [Empty()]
    }

    /// Build an array.
    public static func buildArray(_ components: [[LibraryComponent]]) -> [LibraryComponent] {
        components.flatten()
    }

    /// Build the final ``RootDirectory`` result.
    public static func buildFinalResult(_ component: [LibraryComponent]) -> RootDirectory {
        RootDirectory(content: component)
    }
}
