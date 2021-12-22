//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents `init(from decoder: Decoder)` initializer of a Decodable object
struct DecoderInitializer: SourceCodeRenderable {
    /// All properties of the object that this initializer belongs to
    private let properties: [TypeProperty]
    /// Deleted properties of the object if any
    private let removed: [PropertyChange.RemovalChange]
    private let updateChanges: [PropertyChange.UpdateChange]
    
    /// Initializer
    init(
        properties: [TypeProperty],
        removed: [PropertyChange.RemovalChange] = [],
        changes: [PropertyChange.UpdateChange] = []
    ) {
        self.properties = properties
        self.removed = removed
        self.updateChanges = changes
    }
    
    /// Returns the corresponding line of `property` inside of the initializer by considering potential changes of the property
    private func decodingLine(for property: TypeProperty) -> String {
        if let removalChange = removed.first(where: {  $0.id == property.deltaIdentifier }) {
            if let fallbackValue = removalChange.fallbackValue {
                return "\(property.name) = try \(property.type.unsafeTypeString).instance(from: \(fallbackValue))"
            } else {
                return "\(property.name) = nil"
            }
        }

        guard let change = updateChanges.first(where: { $0.id == property.deltaIdentifier }) else {
            return property.decoderInitLine
        }

        // I'm honestly not sure why we don't support both changes at the same time (and only one change per property)
        // I'm just rewriting the thing and don't really have the time to fix things.

        if case let .necessity(from, to, migration) = change.updated {
            if to != .optional {
                return property.decoderInitLine
            }

            return """
                   \(property.name) = try container.decodeIfPresent\
                   (\(property.type.unsafeTypeString).self, forKey: .\(property.name)) \
                   ?? (try \(property.type.unsafeTypeString).instance(from: \(migration)))
                   """
        } else if case let .type(from, to, forwardMigration, backwardMigration, hint) = change.updated {
            let decodeMethod = "decode\(to.isOptional ? "IfPresent" : "")"
            return """
                   \(property.name) = try \(property.type.unsafeTypeString).from(\
                   try container.\(decodeMethod)(\(to.unsafeTypeString.dropQuestionMark).self, forKey: .\(property.name)), script: \(backwardMigration)\
                   )
                   """
        }

        // TODO warning unsupported update!!!
        return property.decoderInitLine
    }
    
    /// Renders the content of the initializer in a non-formatted way
    var renderableContent: String {
        "public init(from decoder: Decoder) throws {"
        Indent {
            "let container = try decoder.container(keyedBy: CodingKeys.self)"
            ""

            for property in properties {
                decodingLine(for: property)
            }
        }
        "}"
    }
}

/// TypeProperty extension
private extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init(from decoder: Decoder)` if no change affected the property
    var decoderInitLine: String {
        let decodeMethodString = "decode\(type.isOptional ? "IfPresent" : "")"
        return "\(name) = try container.\(decodeMethodString)(\(type.unsafeTypeString.dropQuestionMark).self, forKey: .\(name))"
    }
}
