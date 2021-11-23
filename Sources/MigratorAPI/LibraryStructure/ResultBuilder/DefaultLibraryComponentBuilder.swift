//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

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

    public static func buildArray(_ components: [[LibraryComponent]]) -> [LibraryComponent] {
        components.flatten()
    }
}
