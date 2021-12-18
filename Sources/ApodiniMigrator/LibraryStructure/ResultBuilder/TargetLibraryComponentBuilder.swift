//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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

    public static func buildOptional(_ component: [TargetDirectory]?) -> [TargetDirectory] {
        component ?? []
    }

    public static func buildArray(_ components: [[TargetDirectory]]) -> [TargetDirectory] {
        components.flatten()
    }
}
