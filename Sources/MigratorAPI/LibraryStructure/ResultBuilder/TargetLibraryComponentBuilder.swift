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
}
