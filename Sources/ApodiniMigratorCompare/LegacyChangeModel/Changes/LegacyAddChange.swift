//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents an add change
public struct LegacyAddChange: LegacyChange {
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
    public let element: LegacyChangeElement
    /// Type of change, always `.addition`
    public let type: LegacyChangeType
    /// The added value
    public let added: LegacyChangeValue
    /// Default value of the added value
    public let defaultValue: LegacyChangeValue
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    /// Provider support field if `MigrationGuide.providerSupport` is set to `true`
    public let providerSupport: LegacyProviderSupport?
    
    /// Initializer for a new add change instance
    init(
        element: LegacyChangeElement,
        added: LegacyChangeValue,
        defaultValue: LegacyChangeValue,
        breaking: Bool,
        solvable: Bool,
        includeProviderSupport: Bool = false
    ) {
        self.element = element
        self.added = added
        self.defaultValue = defaultValue
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = includeProviderSupport ? .renameHint(Self.self) : nil
        type = .addition
    }
}
