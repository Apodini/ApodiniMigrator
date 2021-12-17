//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents `encode(to:)` method of an Encodable object
struct EncodingMethod: SourceCodeRenderable {
    /// The properties of the object that this method belongs to (not including deleted ones)
    private let properties: [TypeProperty]
    private let updateChanges: [PropertyChange.UpdateChange]
    
    /// Initializer for a new instance with non-deleted properties of the object, necessity changes and convert changes
    init(properties: [TypeProperty], changes: [PropertyChange.UpdateChange] = []) {
        self.properties = properties
        self.updateChanges = changes
    }
    
    /// Returns the corresponding line of the property inside of the method by considering all changes related with the property
    private func encodingLine(for property: TypeProperty) -> String {
        guard let change = updateChanges.first(where: { $0.id == property.deltaIdentifier }) else {
            return property.encodingMethodLine
        }

        // I'm honestly not sure why we don't support both changes at the same time (and only one change per property)
        // I'm just rewriting the thing and don't really have the time to fix things.

        if case let .necessity(from, to, migration) = change.updated {
            return """
                   try container.encode(\(property.name) \
                   ?? (try \(property.type.unwrapped.typeString)\
                   .instance(from: \(migration))), forKey: .\(property.name))
                   """
        } else if case let .type(from, to, forwardMigration, backwardMigration, hint) = change.updated {
            let encodeMethod = "encode\(to.isOptional ? "IfPresent" : "")"
            return """
                   try container.\(encodeMethod)(try \(to.typeString)\
                   .from(\(property.name), script: \(forwardMigration)), forKey: .\(property.name))
                   """
        }

        // TODO warning unsupported update!!!
        return property.encodingMethodLine
    }
    
    /// Renders the content of the method in a non-formatted way
    var renderableContent: String {
        "public func encode(to encoder: Encoder) throws {"
        Indent {
            "var container = encoder.container(keyedBy: CodingKeys.self)"
            ""

            for property in properties {
                encodingLine(for: property)
            }
        }
        "}"
    }
}

/// TypeProperty extension
private extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `encode(to:)` method if the property is not affected by any change
    var encodingMethodLine: String {
        let encodeMethodString = "encode\(type.isOptional ? "IfPresent" : "")"
        return "try container.\(encodeMethodString)(\(name), forKey: .\(name))"
    }
}
