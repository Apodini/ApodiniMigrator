//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The ``LibraryComponent`` builder to build a ``TargetDirectory`` of a swift package.
@resultBuilder
public enum TargetLibraryComponentBuilder<Target: TargetDirectory> {
    /// Build an expression from a `Target` directory.
    /// - Parameter expression: The `Target` directory expression.
    /// - Returns: Returns the component
    public static func buildExpression(_ expression: Target) -> [TargetDirectory] {
        [expression]
    }

    /// Build a block from ``TargetDirectory``s.
    /// - Parameter components: The components
    /// - Returns: Returns the component.
    public static func buildBlock(_ components: [TargetDirectory]...) -> [TargetDirectory] {
        components.flatten()
    }

    /// Build either first.
    public static func buildEither(first component: [TargetDirectory]) -> [TargetDirectory] {
        component
    }

    /// Build either second.
    public static func buildEither(second component: [TargetDirectory]) -> [TargetDirectory] {
        component
    }

    /// Build an optional expression.
    public static func buildOptional(_ component: [TargetDirectory]?) -> [TargetDirectory] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    /// Build an array.
    public static func buildArray(_ components: [[TargetDirectory]]) -> [TargetDirectory] {
        components.flatten()
    }
}
