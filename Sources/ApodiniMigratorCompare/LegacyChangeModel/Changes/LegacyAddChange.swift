//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents an add change
struct LegacyAddChange: LegacyChange {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case element
        case type = "change-type"
        case added = "added-value"
        case defaultValue = "default-value"
        case breaking
        case solvable
        case providerSupport = "provider-support"
    }
    
    /// Top-level changed element related to the change
    let element: LegacyChangeElement
    /// Type of change, always `.addition`
    let type: LegacyChangeType
    /// The added value
    let added: LegacyChangeValue
    /// Default value of the added value
    let defaultValue: LegacyChangeValue
    /// Indicates whether the change is non-backward compatible
    let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    let solvable: Bool
    /// Provider support field if `MigrationGuide.providerSupport` is set to `true`
    let providerSupport: LegacyProviderSupport?
}
