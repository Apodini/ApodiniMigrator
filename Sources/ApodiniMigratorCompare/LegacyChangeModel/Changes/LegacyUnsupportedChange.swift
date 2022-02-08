//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents an unsupported change from `ApodiniMigrator`,
/// E.g. a type changes from an `enum` to an `object` or vice versa
struct LegacyUnsupportedChange: LegacyChange {
    /// Top-level changed element related to the change
    let element: LegacyChangeElement
    /// Type of the change, always `.unsupported`
    let type: LegacyChangeType
    /// A textual description of the reason
    let description: String
    /// Indicates whether the change is non-backward compatible, always `true`
    let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`, always `false`
    let solvable: Bool
}
