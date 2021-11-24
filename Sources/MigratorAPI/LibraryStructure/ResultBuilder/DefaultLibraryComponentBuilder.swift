//
// Created by Andreas Bauer on 15.11.21.
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
