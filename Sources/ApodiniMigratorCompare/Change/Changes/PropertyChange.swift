//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

/// Represents a change of a property of an object
public struct PropertyChange: Change {
    private enum CodingKeys: String, CodingKey {
        case element
        case type
        case targetID = "target-id"
        case from
        case to
        case convertTo = "convert-to-method"
        case convertFrom = "convert-from-method"
        case breaking
        case solvable
    }
    /// Top-level changed element related to the change, always `.object`
    public let element: ChangeElement
    /// Type of the change, always `.propertyChange`
    public let type: ChangeType
    /// Id of the affected property
    public let targetID: DeltaIdentifier?
    /// Type information that the property was updated from
    public let from: TypeInformation
    /// Type information that the property was updated to
    public let to: TypeInformation
    /// JS convert function to convert old type to new type
    public let convertTo: String
    /// JS convert function to convert new type to old type
    public let convertFrom: String
    /// Indicates whether the change is non-backward compatible
    public let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    public let solvable: Bool
    
    /// Initializer for a new property change instance
    init(
        element: ChangeElement,
        targetID: DeltaIdentifier,
        from: TypeInformation,
        to: TypeInformation,
        convertTo: String,
        convertFrom: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.targetID = targetID
        self.from = from
        self.to = to
        self.convertTo = convertTo
        self.convertFrom = convertFrom
        self.breaking = breaking
        self.solvable = solvable
        type = .propertyChange
    }
}
