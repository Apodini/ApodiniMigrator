//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO some code duplication between all result builders

@resultBuilder
public enum DefaultLibraryComponentBuilder {
    public static func buildExpression(_ expression: LibraryNode) -> [LibraryComponent] {
        [expression]
    }

    public static func buildExpression(_ expression: LibraryComposite) -> [LibraryComponent] {
        [expression]
    }

    public static func buildBlock(_ components: [LibraryComponent]...) -> [LibraryComponent] {
        components.flatten()
    }

    public static func buildEither(first component: [LibraryComponent]) -> [LibraryComponent] {
        component
    }

    public static func buildEither(second component: [LibraryComponent]) -> [LibraryComponent] {
        component
    }

    public static func buildOptional(_ component: [LibraryComponent]?) -> [LibraryComponent] {
        component ?? [Empty()]
    }

    public static func buildArray(_ components: [[LibraryComponent]]) -> [LibraryComponent] {
        components.flatten()
    }
}
