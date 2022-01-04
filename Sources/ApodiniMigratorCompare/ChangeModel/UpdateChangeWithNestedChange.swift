//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// An optional protocol a update change type of a ``ChangeableElement`` can implement
/// to signify that it may contain nested ``Change`` types.
/// This is useful to remove duplicated `breaking` and `solvable` classifications from encoding.
public protocol UpdateChangeWithNestedChange {
    /// Defines if this instance is a nested ``Change``.
    var isNestedChange: Bool { get }

    /// In the case of a nested ``Change``, it returns the `breaking` classification.
    var nestedBreakingClassification: Bool? { get } // swiftlint:disable:this discouraged_optional_boolean
    /// In the case of a nested ``Change``, it returns the `solvable` classification.
    var nestedSolvableClassification: Bool? { get } // swiftlint:disable:this discouraged_optional_boolean
}
