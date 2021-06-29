//
//  DecoderInitializer.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents `init(from decoder: Decoder)` initializer of a Decodable object
struct DecoderInitializer: Renderable {
    /// All properties of the object that this initializer belongs to
    let properties: [TypeProperty]
    /// Deleted properties of the object if any
    let deleted: [DeletedProperty]
    /// Necessity changes related to the properties of the object
    let necessityChanges: [UpdateChange]
    /// Convert changes related to the properties of the object
    let convertChanges: [UpdateChange]
    
    /// Initializer
    init(
        _ properties: [TypeProperty],
        deleted: [DeletedProperty] = [],
        necessityChanges: [UpdateChange] = [],
        convertChanges: [UpdateChange] = []
    ) {
        self.properties = properties
        self.deleted = deleted
        self.necessityChanges = necessityChanges
        self.convertChanges = convertChanges
    }
    
    /// Returns the corresponding line of `property` inside of the initializer by considering potential changes of the property
    private func decodingLine(for property: TypeProperty) -> String {
        let id = property.deltaIdentifier
        let name = property.name
        if let deletedProperty = deleted.firstMatch(on: \.id, with: id) {
            let valueString: String
            if case let .json(id) = deletedProperty.fallbackValue {
                valueString = "try \(property.type.typeString).instance(from: \(id))"
            } else {
                assert(deletedProperty.fallbackValue.isNone && property.necessity == .optional, "Migration guide did not provide a default value for the deleted property: \(name)")
                valueString = "nil"
            }
            return "\(name) = \(valueString)"
        } else if let change = necessityChanges.firstMatch(on: \.targetID, with: id),
                  let necessityValue = change.necessityValue,
                  case let .element(anyCodable) = change.to,
                  anyCodable.typed(Necessity.self) == .optional,
                  case let .json(id) = necessityValue {
            return "\(name) = try container.decodeIfPresent(\(property.type.typeString).self, forKey: .\(name)) ?? (try \(property.type.typeString).instance(from: \(id)))"
        } else if let change = convertChanges.firstMatch(on: \.targetID, with: id),
                  case let .element(anyCodable) = change.to,
                  let scriptID = change.convertToFrom {
            let newType = anyCodable.typed(TypeInformation.self)
            let decodeMethod = "decode\(newType.isOptional ? "IfPresent" : "")"
            return "\(name) = try \(property.type.typeString).from(try container.\(decodeMethod)(\(newType.typeString.dropQuestionMark).self, forKey: .\(name)), script: \(scriptID))"
        } else {
            return property.decoderInitLine
        }
    }
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        \(properties.map { "\(decodingLine(for: $0))" }.lineBreaked)
        }
        """
    }
}

/// TypeProperty extension
fileprivate extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init(from decoder: Decoder)` if no change affected the property
    var decoderInitLine: String {
        let decodeMethodString = "decode\(type.isOptional ? "IfPresent" : "")"
        return "\(name) = try container.\(decodeMethodString)(\(type.typeString.dropQuestionMark).self, forKey: .\(name))"
    }
}
