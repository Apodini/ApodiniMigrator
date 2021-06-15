//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

/// Represents an update change, the most frequent change that can appear in the Migration guide
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
        case convertFunction = "convert-method"
    }
    
    /// Top-level changed element related to the change
    public let element: ChangeElement
    /// Type of change, can either be `.update` or `.rename`
    public let type: ChangeType
    /// Old value of the target
    public let from: ChangeValue
    /// Old value of the target
    public let to: ChangeValue
    /// Optional id of the target
    public let targetID: DeltaIdentifier?
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    /// An optional string property to cover the case if the target change is `typeInformation`, e.g. the response of an endpoint
    public let convertFunction: String?
    
    /// Initializer for an UpdateChange with type `.update`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        targetID: DeltaIdentifier? = nil,
        convertFunction: String? = nil,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = targetID
        self.convertFunction = convertFunction
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
        convertFunction = nil
        targetID = nil
        type = .rename
    }
}
