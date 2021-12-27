//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct LegacyDeleteChange: LegacyChange {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case element
        case type = "change-type"
        case deleted = "deleted-value"
        case fallbackValue = "fallback-value"
        case breaking
        case solvable
        case providerSupport = "provider-support"
    }
    
    /// Top-level changed element related to the change
    let element: LegacyChangeElement
    /// Type of change, always `.deletion`
    let type: LegacyChangeType
    /// Deleted value
    let deleted: LegacyChangeValue
    /// Fallback value for the deleted value
    let fallbackValue: LegacyChangeValue
    /// Indicates whether the change is non-backward compatible
    let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    let solvable: Bool
    /// Provider support field if `MigrationGuide.providerSupport` is set to `true`
    let providerSupport: LegacyProviderSupport?
}
