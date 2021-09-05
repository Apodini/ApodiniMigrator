//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents initializer of an object
struct ObjectInitializer: Renderable {
    /// All properties of the object that this initializer belongs to (including added and deleted properties
    private let properties: [TypeProperty]
    /// Dictionary of default values of the added properties of the object
    private var defaultValues: [DeltaIdentifier: ChangeValue]
    
    /// Initializes a new instance out of old properties of the object and the added properties
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
    
    /// Returns the string of the type of the property appending a corresponding default value for added properties as provided in the migration guide
    private func defaultValue(for property: TypeProperty) -> String {
        var typeString = property.type.typeString
        if let defaultValue = defaultValues[property.deltaIdentifier] {
            let defaultValueString: String
            if case let .json(id) = defaultValue {
                defaultValueString = "try! \(typeString).instance(from: \(id))"
            } else {
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
