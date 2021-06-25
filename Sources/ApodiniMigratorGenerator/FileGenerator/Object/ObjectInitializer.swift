//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

/// Represents initializer of an object
struct ObjectInitializer: Renderable {
    /// The properties of the object that this initializer belongs to
    var properties: [TypeProperty]
    var defaultValueIDs: [DeltaIdentifier: Int]
    
    /// Initializer
    init(_ properties: [TypeProperty], addedProperties: [AddedProperty] = []) {
        var allProperties = properties
        defaultValueIDs = [:]
        for added in addedProperties {
            defaultValueIDs[added.typeProperty.deltaIdentifier] = added.jsonValueID
            allProperties.append(added.typeProperty)
        }
        self.properties = allProperties.sorted(by: \.name)
       
    }
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        public init(
        \(properties.map { "\($0.name): \(defaultValue(for: $0))" }.joined(separator: ",\(String.lineBreak)"))
        ) {
        \(properties.map { "\($0.initLine)" }.lineBreaked)
        }
        """
    }
    
    private func defaultValue(for property: TypeProperty) -> String {
        var typeString = property.type.typeString
        if let id = defaultValueIDs[property.deltaIdentifier] {
            typeString += " = try! \(typeString).instance(from: \(id))"
        }
        return typeString
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init`
    var initLine: String {
        "self.\(name) = \(name)"
    }
}
