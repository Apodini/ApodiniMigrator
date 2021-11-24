//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

@resultBuilder
public enum RootLibraryComponentBuilder {
    public static func buildExpression(_ expression: Sources) -> [LibraryComponent] {
        [expression]
    }

    public static func buildExpression(_ expression: Tests) -> [LibraryComponent] {
        [expression]
    }

    // TODO we currently do not allow ANY directories?

    public static func buildExpression(_ expression: LibraryNode) -> [LibraryComponent] {
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

    public static func buildFinalResult(_ component: [LibraryComponent]) -> RootDirectory {
        RootDirectory(content: component)
    }
}
