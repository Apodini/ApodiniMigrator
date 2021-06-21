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

/// Represents an update change of an arbitrary element from some old value to some new value,
/// the most frequent change that can appear in the Migration guide. Depending on the change element
/// and the target, the type of an update change can either be a generic `.update` or a `.rename`, `.propertyChange`, `.parameterChange` or `.responseChange`,
/// which can be initialized through different initalizers
public struct UpdateChange: Change {
    // MARK: Private Inner Types
    enum CodingKeys: String, CodingKey {
        case element
        case type = "change-type"
        case parameterTarget = "parameter-target"
        case targetID = "target-id"
        case from
        case to
        case convertTo = "convert-to-method"
        case convertFrom = "convert-from-method"
        case breaking
        case solvable
        case providerSupport = "provider-support"
    }
    
    /// Top-level changed element related to the change
    public let element: ChangeElement
    /// Type of change, can either be a generic `.update` or a `.rename`, `.propertyChange`, `.parameterChange` or `.responseChange`
    public let type: ChangeType
    /// Old value of the target
    public let from: ChangeValue
    /// New value of the target
    public let to: ChangeValue
    /// Optional id of the target
    public let targetID: DeltaIdentifier?
    /// JS convert function to convert old type to new type, e.g. if the change element is an endpoint and the target is the response
    public let convertTo: JSScript?
    /// JS convert function to convert new type to old type, e.g. if the change element is an object and the target is property
    public let convertFrom: JSScript?
    /// The target of the parameter which is related to the change if type is a `parameterChange`
    public let parameterTarget: ParameterChangeTarget?
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    /// Provider support field if change type is a rename and `MigrationGuide.providerSupport` is set to `true`
    public let providerSupport: ProviderSupport?
    
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
        self.parameterTarget = nil
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = nil
        type = .update
    }
    
    /// Initializer for an UpdateChange with type `.rename`
    init(
        element: ChangeElement,
        from: String,
        to: String,
        breaking: Bool,
        solvable: Bool,
        includeProviderSupport: Bool
    ) {
        self.element = element
        self.from = .stringValue(from)
        self.to = .stringValue(to)
        targetID = nil
        convertTo = nil
        convertFrom = nil
        self.parameterTarget = nil
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = includeProviderSupport ? .renameValidationHint : nil
        type = .rename
    }
    
    /// Initializer for an UpdateChange with type `.responseChange`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        convertTo: JSScript,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = nil
        self.convertTo = convertTo
        self.convertFrom = nil
        self.parameterTarget = nil
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = nil
        type = .responseChange
    }
    
    /// Initializer for an UpdateChange with type `.propertyChange`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        targetID: DeltaIdentifier,
        convertTo: JSScript,
        convertFrom: JSScript,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = targetID
        self.convertTo = convertTo
        self.convertFrom = convertFrom
        self.parameterTarget = nil
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = nil
        type = .propertyChange
    }
    
    /// Initializer for an UpdateChange with type `.parameterChange`
    init(
        element: ChangeElement,
        from: ChangeValue,
        to: ChangeValue,
        targetID: DeltaIdentifier,
        convertTo: JSScript? = nil,
        parameterTarget: ParameterChangeTarget,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.targetID = targetID
        self.convertTo = convertTo
        self.convertFrom = nil
        self.parameterTarget = parameterTarget
        self.breaking = breaking
        self.solvable = solvable
        self.providerSupport = nil
        type = .parameterChange
    }
}
