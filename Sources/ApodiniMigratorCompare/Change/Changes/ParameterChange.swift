//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation


public enum ParameterChangeTarget: String, Value {
    case necessity
    case kind
    case typeInformation = "type"
}

/// Represents a parameter change
public struct ParameterChange: Change {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case element
        case type
        case targetID = "target-id"
        case parameterTarget = "parameter-target"
        case from
        case to
        case convertFunction = "convert-method"
        case breaking
        case solvable
    }
    
    /// Top-level changed element related to the change, always an endpoint
    public let element: ChangeElement
    /// Type of the change, always `.parameterChange`
    public let type: ChangeType
    /// The id of the parameter
    public let targetID: DeltaIdentifier
    /// The target of the parameter which is related to the change
    public let parameterTarget: ParameterChangeTarget
    /// Old value of the parameter target
    public let from: ChangeValue
    /// Updated value of the parameter target
    public let to: ChangeValue
    /// An optional string property to cover the case if the target of parameter change is `typeInformation`
    public let convertFunction: String?
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    
    /// Initializer for a new change instance
    init(
        element: ChangeElement,
        targetID: DeltaIdentifier,
        parameterTarget: ParameterChangeTarget,
        from: ChangeValue,
        to: ChangeValue,
        convertFunction: String? = nil,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.targetID = targetID
        self.parameterTarget = parameterTarget
        self.from = from
        self.to = to
        self.convertFunction = convertFunction
        self.breaking = breaking
        self.solvable = solvable
        type = .parameterChange
    }
}
