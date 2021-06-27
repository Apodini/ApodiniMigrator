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
    var defaultValues: [DeltaIdentifier: ChangeValue]
    
    /// Initializer
    init(_ properties: [TypeProperty], addedProperties: [AddedProperty] = []) {
        var allProperties = properties
        defaultValues = [:]
        for added in addedProperties {
            defaultValues[added.typeProperty.deltaIdentifier] = added.defaultValue
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
        if let defaultValue = defaultValues[property.deltaIdentifier] {
            let defaultValueString: String
            if case let .json(id) = defaultValue {
                defaultValueString = "try! \(typeString).instance(from: \(id))"
            } else {
                assert(defaultValue.isNone && property.necessity == .optional, "Migration guide did not provide a json id for a non-optional property: \(property.name)")
                defaultValueString = "nil"
            }
            typeString += " = \(defaultValueString)"
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
