//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents `init(from decoder: Decoder)` initializer of a Decodable object
struct DecoderInitializer: Renderable {
    /// The properties of the object that this initializer belongs to
    let properties: [TypeProperty]
    let deleted: [DeletedProperty]
    let necessityChanges: [UpdateChange]
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
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        \(properties.map { "\(decodingLine(for: $0))" }.lineBreaked)
        }
        """
    }
    
    func decodingLine(for property: TypeProperty) -> String {
        let id = property.deltaIdentifier
        let name = property.name
        if property.necessity == .required, let deletedProperty = deleted.firstMatch(on: \.id, with: id) {
            return "\(name) = try \(property.type.typeString).instance(from: \(deletedProperty.jsonValueID))"
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
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init(from decoder: Decoder)`
    var decoderInitLine: String {
        let decodeMethodString = "decode\(type.isOptional ? "IfPresent" : "")"
        return "\(name) = try container.\(decodeMethodString)(\(type.typeString.dropQuestionMark).self, forKey: .\(name))"
    }
}
