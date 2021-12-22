//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct LegacyDeleteChange: LegacyChange {
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
    public let element: LegacyChangeElement
    /// Type of change, always `.deletion`
    public let type: LegacyChangeType
    /// Deleted value
    public let deleted: LegacyChangeValue
    /// Fallback value for the deleted value
    public let fallbackValue: LegacyChangeValue
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    /// Provider support field if `MigrationGuide.providerSupport` is set to `true`
    public let providerSupport: LegacyProviderSupport?
    
    /// Initializer for a new delete change instance
    init(
        element: LegacyChangeElement,
        deleted: LegacyChangeValue,
        fallbackValue: LegacyChangeValue,
        breaking: Bool,
        solvable: Bool,
        includeProviderSupport: Bool = false
    ) {
        self.element = element
        self.deleted = deleted
        self.fallbackValue = fallbackValue
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = includeProviderSupport ? .renameHint(Self.self) : nil
        type = .deletion
    }
}
