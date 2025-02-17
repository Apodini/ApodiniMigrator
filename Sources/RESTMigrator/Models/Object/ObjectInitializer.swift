//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents initializer of an object
struct ObjectInitializer: SourceCodeRenderable {
    /// All properties of the object that this initializer belongs to (including added and deleted properties
    private let properties: [TypeProperty]
    /// Dictionary of default values of the added properties of the object
    private var defaultValues: [DeltaIdentifier: Int?]
    
    /// Initializes a new instance out of old properties of the object and the added properties
    init(_ properties: [TypeProperty], addedProperties: [PropertyChange.AdditionChange] = []) {
        var allProperties = properties
        defaultValues = [:]
        for added in addedProperties {
            defaultValues[added.id] = added.defaultValue
            allProperties.append(added.added)
        }
        self.properties = allProperties.sorted(by: \.name)
    }
    
    /// Renders the content of the initializer in a non-formatted way
    var renderableContent: String {
        "public init("
        Indent {
            properties
                .map { "\($0.name): \(defaultValue(for: $0))" }
                .joined(separator: ",\n")
        }
        ") {"
        Indent {
            for property in properties {
                property.initLine
            }
        }
        "}"
    }
    
    /// Returns the string of the type of the property appending a corresponding default value for added properties as provided in the migration guide
    private func defaultValue(for property: TypeProperty) -> String {
        var typeString = property.type.unsafeTypeString
        if let defaultValueEntry: Int? = defaultValues[property.deltaIdentifier] {
            let defaultValueString: String
            if let defaultValue = defaultValueEntry {
                defaultValueString = "try! \(typeString).instance(from: \(defaultValue))"
            } else {
                defaultValueString = "nil"
            }
            typeString += " = \(defaultValueString)"
        }
        return typeString
    }
}

/// TypeProperty extension
private extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init`
    var initLine: String {
        "self.\(name) = \(name)"
    }
}
