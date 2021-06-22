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
    let optionalityChanges: [UpdateChange]
    let convertChanges: [UpdateChange]
    
    /// Initializer
    init(_ properties: [TypeProperty], deletedIDs: [DeltaIdentifier] = [], optionalityChanges: [UpdateChange] = [], convertChanges: [UpdateChange] = []) {
        self.properties = properties.filter { !deletedIDs.contains($0.deltaIdentifier) }
        self.optionalityChanges = optionalityChanges
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
        if
            let change = optionalityChanges.first(where: { $0.targetID == property.deltaIdentifier }),
            case let .element(anyCodable) = change.to,
            anyCodable.typed(Optionality.self) == .required {
            return "try container.encode(\(property.name) ?? try \(property.type.typeString).defaultValue(), forKey: .\(property.name))"
        } else if let change = convertChanges.first(where: { $0.targetID == property.deltaIdentifier }), case let .element(anyCodable) = change.to, let convertToScript = change.convertFromTo {
            let newType = anyCodable.typed(TypeInformation.self)
            return "try container.encode\(newType.isOptional ? "IfPresent" : "")(try \(newType.typeString).from(\(property.name), script: \(convertToScript)), forKey: .\(property.name))"
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
