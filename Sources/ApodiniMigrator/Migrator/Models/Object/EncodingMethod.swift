//
//  EncodingMethod.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents `encode(to:)` method of an Encodable object
struct EncodingMethod: Renderable {
    /// The properties of the object that this method belongs to (not including deleted ones)
    private let properties: [TypeProperty]
    /// Necessity changes related with the properties of the object
    private let necessityChanges: [UpdateChange]
    /// Convert changes related with the properties of the object
    private let convertChanges: [UpdateChange]
    
    /// Initializer for a new instance with non-deleted properties of the object, necessity changes and convert changes
    init(_ properties: [TypeProperty], necessityChanges: [UpdateChange] = [], convertChanges: [UpdateChange] = []) {
        self.properties = properties
        self.necessityChanges = necessityChanges
        self.convertChanges = convertChanges
    }
    
    /// Returns the corresponding line of the property inside of the method by considering all changes related with the property
    private func encodingLine(for property: TypeProperty) -> String {
        let id = property.deltaIdentifier
        let name = property.name
        if
            let change = necessityChanges.firstMatch(on: \.targetID, with: id),
            let necessityValue = change.necessityValue,
            case let .element(anyCodable) = change.to,
            anyCodable.typed(Necessity.self) == .required,
            case let .json(id) = necessityValue {
            return "try container.encode(\(name) ?? (try \(property.type.unwrapped.typeString).instance(from: \(id))), forKey: .\(name))"
        } else if
            let change = convertChanges.firstMatch(on: \.targetID, with: id),
            case let .element(anyCodable) = change.to,
            let scriptID = change.convertFromTo
        {
            let newType = anyCodable.typed(TypeInformation.self)
            let encodeMethod = "encode\(newType.isOptional ? "IfPresent" : "")"
            return "try container.\(encodeMethod)(try \(newType.typeString).from(\(name), script: \(scriptID)), forKey: .\(name))"
        } else {
            return property.encodingMethodLine
        }
    }
    
    /// Renders the content of the method in a non-formatted way
    func render() -> String {
        """
        public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        \(properties.map { "\(encodingLine(for: $0))" }.lineBreaked)
        }
        """
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `encode(to:)` method if the property is not affected by any change
    var encodingMethodLine: String {
        let encodeMethodString = "encode\(type.isOptional ? "IfPresent" : "")"
        return "try container.\(encodeMethodString)(\(name), forKey: .\(name))"
    }
}
