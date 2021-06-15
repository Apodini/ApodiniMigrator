//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

public struct DeleteChange: Change {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case element
        case type
        case deleted = "deleted-value"
        case fallbackValue = "fallback-value"
        case breaking
        case solvable
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
    
    /// Initializer for a new delete change instance
    init(
        element: ChangeElement,
        deleted: ChangeValue,
        fallbackValue: ChangeValue,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.deleted = deleted
        self.fallbackValue = fallbackValue
        self.breaking = breaking
        self.solvable = solvable
        type = .deletion
    }
}
