//
//  DeleteChange.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public struct DeleteChange: Change {
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
    public let element: ChangeElement
    /// Type of change, always `.deletion`
    public let type: ChangeType
    /// Deleted value
    public let deleted: ChangeValue
    /// Fallback value for the deleted value
    public let fallbackValue: ChangeValue
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    /// Provider support field if `MigrationGuide.providerSupport` is set to `true`
    public let providerSupport: ProviderSupport?
    
    /// Initializer for a new delete change instance
    init(
        element: ChangeElement,
        deleted: ChangeValue,
        fallbackValue: ChangeValue,
        breaking: Bool,
        solvable: Bool,
        includeProviderSupport: Bool
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
