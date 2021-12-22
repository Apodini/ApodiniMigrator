//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents an unsupported change from `ApodiniMigrator`,
/// E.g. a type changes from an `enum` to an `object` or vice versa
public struct LegacyUnsupportedChange: LegacyChange {
    /// Top-level changed element related to the change
    public let element: LegacyChangeElement
    /// Type of the change, always `.unsupported`
    public let type: LegacyChangeType
    /// A textual description of the reason
    public let description: String
    /// Indicates whether the change is non-backward compatible, always `true`
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`, always `false`
    public let solvable: Bool
    
    /// Initializer for an unsupported change
    init(element: LegacyChangeElement, description: String) {
        self.element = element
        self.breaking = true
        self.solvable = false
        self.description = description
        type = .unsupported
    }
}
