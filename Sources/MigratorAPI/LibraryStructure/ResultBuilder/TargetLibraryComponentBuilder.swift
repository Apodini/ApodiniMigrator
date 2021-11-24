//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

@resultBuilder
public enum TargetLibraryComponentBuilder<Target: TargetDirectory> {
    public static func buildExpression(_ expression: Target) -> [TargetDirectory] {
        [expression]
    }

    public static func buildBlock(_ components: [TargetDirectory]...) -> [TargetDirectory] {
        components.flatten()
    }

    public static func buildEither(first component: [TargetDirectory]) -> [TargetDirectory] {
        component
    }

    public static func buildEither(second component: [TargetDirectory]) -> [TargetDirectory] {
        component
    }

    // TODO buildOptional?

    public static func buildArray(_ components: [[TargetDirectory]]) -> [TargetDirectory] {
        components.flatten()
    }
}
