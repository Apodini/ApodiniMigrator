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
    var sortedProperties: [TypeProperty]
    var defaultValues: [DeltaIdentifier: String]
    
    /// Initializer
    init(_ properties: [TypeProperty], addedProperties: [AddedProperty] = []) {
        var allProperties = properties
        defaultValues = [:]
        for added in addedProperties {
            defaultValues[added.typeProperty.deltaIdentifier] = added.defaultValueJSON
            allProperties.append(added.typeProperty)
        }
        sortedProperties = allProperties.sorted(by: \.name)
       
    }
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        public init(
        \(sortedProperties.map { "\($0.name): \(defaultValue(for: $0))" }.joined(separator: ",\(String.lineBreak)"))
        ) {
        \(sortedProperties.map { "\($0.initLine)" }.lineBreaked)
        }
        """
    }
    
    private func defaultValue(for property: TypeProperty) -> String {
        var typeString = property.type.typeString
        if let json = defaultValues[property.deltaIdentifier] {
            typeString += " = try! \(typeString).instance(from: \(json.doubleQuoted))"
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
