//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The general ``LibraryComponent`` builder.
@resultBuilder
public enum DefaultLibraryComponentBuilder {
    /// Build a ``LibraryNode`` expression.
    public static func buildExpression(_ expression: LibraryNode) -> [LibraryComponent] {
        [expression]
    }

    /// Build a ``LibraryComposite`` expression.
    public static func buildExpression(_ expression: LibraryComposite) -> [LibraryComponent] {
        [expression]
    }

    /// Build component block
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
}
