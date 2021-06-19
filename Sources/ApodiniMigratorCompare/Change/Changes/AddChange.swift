//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

/// Represents an add change
public struct AddChange: Change {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case element
        case type = "change-type"
        case added = "added-value"
        case defaultValue = "default-value"
        case breaking
        case solvable
    }
    
    /// Top-level changed element related to the change
    public let element: ChangeElement
    /// Type of change, always `.addition`
    public let type: ChangeType
    /// The added value
    public let added: ChangeValue
    /// Default value of the added value
    public let defaultValue: ChangeValue
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    
    /// Initializer for a new add change instance
    init(
        element: ChangeElement,
        added: ChangeValue,
        defaultValue: ChangeValue,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.added = added
        self.defaultValue = defaultValue
        self.breaking = breaking
        self.solvable = solvable
        type = .addition
    }
}
