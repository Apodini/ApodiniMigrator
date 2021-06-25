//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents `encode(to:)` method of an Encodable object
struct EncodingMethod: Renderable {
    /// The properties of the object that this method belongs to
    let properties: [TypeProperty]
    let necessityChanges: [UpdateChange]
    let convertChanges: [UpdateChange]
    
    /// Initializer
    init(_ properties: [TypeProperty], necessityChanges: [UpdateChange] = [], convertChanges: [UpdateChange] = []) {
        self.properties = properties
        self.necessityChanges = necessityChanges
        self.convertChanges = convertChanges
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
    
    func encodingLine(for property: TypeProperty) -> String {
        let id = property.deltaIdentifier
        let name = property.name
        if
            let change = necessityChanges.firstMatch(on: \.targetID, with: id),
            let necessityValue = change.necessityValue,
            case let .element(anyCodable) = change.to,
            anyCodable.typed(Necessity.self) == .required,
            case let .json(id) = necessityValue {
            return "try container.encode(\(name) ?? (try \(property.type.unwrapped.typeString).instance(from: \(id))), forKey: .\(name))"
        } else if let change = convertChanges.firstMatch(on: \.targetID, with: id), case let .element(anyCodable) = change.to, let scriptID = change.convertFromTo {
            let newType = anyCodable.typed(TypeInformation.self)
            let encodeMethod = "encode\(newType.isOptional ? "IfPresent" : "")"
            return "try container.\(encodeMethod)(try \(newType.typeString).from(\(name), script: \(scriptID)), forKey: .\(name))"
        } else {
            return property.encodingMethodLine
        }
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `encode(to:)` method
    var encodingMethodLine: String {
        let encodeMethodString = "encode\(type.isOptional ? "IfPresent" : "")"
        return "try container.\(encodeMethodString)(\(name), forKey: .\(name))"
    }
}
