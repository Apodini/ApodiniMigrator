//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

/// Represents an update change of an arbitrary element from some old value to some new value,
/// the most frequent change that can appear in the Migration guide. Depending on the change element
/// and the target, the type of an update change can either be a generic `.update`, `.rename`, `.propertyChange` or `.responseChange`,
/// which can be initialized through different initalizers
public struct UpdateChange: Change {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case element
        case type
        case from
        case to
        case targetID = "target-id"
        case breaking
        case solvable
        case convertTo = "convert-to-method"
        case convertFrom = "convert-from-method"
    }
    
    /// Top-level changed element related to the change
    public let element: ChangeElement
    /// Type of change, can either be a generic `.update`, `.rename`, `.propertyChange` or `.responseChange`
    public let type: ChangeType
    /// Old value of the target
    public let from: ChangeValue
    /// New value of the target
    public let to: ChangeValue
    /// Optional id of the target
    public let targetID: DeltaIdentifier?
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    /// JS convert function to convert old type to new type, e.g. if the change element is an endpoint and the target is the response
    public let convertTo: String?
    /// JS convert function to convert new type to old type, e.g. if the change element is an object and the target is property
    public let convertFrom: String?
    
    /// Initializer for an UpdateChange with type `.update`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        targetID: DeltaIdentifier? = nil,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = targetID
        self.convertTo = nil
        self.convertFrom = nil
        self.breaking = breaking
        self.solvable = solvable
        type = .update
    }
    
    /// Initializer for an UpdateChange with type `.rename`
    init(
        element: ChangeElement,
        from: String,
        to: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = .stringValue(from)
        self.to = .stringValue(to)
        self.breaking = breaking
        self.solvable = solvable
        convertTo = nil
        convertFrom = nil
        targetID = nil
        type = .rename
    }
    
    /// Initializer for an UpdateChange with type `.responseChange`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        convertTo: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = nil
        self.convertTo = convertTo
        self.convertFrom = nil
        self.breaking = breaking
        self.solvable = solvable
        type = .responseChange
    }
    
    /// Initializer for an UpdateChange with type `.propertyChange`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        targetID: DeltaIdentifier,
        convertTo: String,
        convertFrom: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = targetID
        self.convertTo = convertTo
        self.convertFrom = convertFrom
        self.breaking = breaking
        self.solvable = solvable
        type = .propertyChange
    }
}
