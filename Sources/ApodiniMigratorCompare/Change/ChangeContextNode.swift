//
//  ChangeContextNode.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A reference object to register changes during comparison of documents of two versions.
/// Used internally in the migration guide generation to be passed in the DocumentComparator. Furthermore
/// handles the logic of encoding and decoding different change types
final class ChangeContextNode: Codable {
    /// Changes of the container
    private(set) var changes: [Change]
    /// Compare config passed from migration guide, property is owned by the migration guide, and does not get encoded or decoded from `self`
    var compareConfiguration: CompareConfiguration?
    
    /// All javascript convert methods created during comparison
    var scripts: [Int: JSScript]
    /// All json values of properties or parameter that require a default or fallback value
    var jsonValues: [Int: JSONValue]
    /// All json representations of objects that had some kind of breaking change in their properties
    private(set) var objectJSONs: [String: JSONValue]
    
    /// Initializes `self` with empty changes
    init(compareConfiguration: CompareConfiguration? = nil) {
        changes = []
        self.compareConfiguration = compareConfiguration
        scripts = [:]
        jsonValues = [:]
        objectJSONs = [:]
    }
    
    /// Encodes `self` into the given encoder via an `unkeyedContainer`
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        for change in changes {
            if let change = change as? AddChange {
                try container.encode(change)
            }
            
            if let change = change as? DeleteChange {
                try container.encode(change)
            }
            
            if let change = change as? UpdateChange {
                try container.encode(change)
            }
        }
    }
    
    /// Creates a new instance by decoding from the given decoder
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.changes = []
        scripts = [:]
        jsonValues = [:]
        objectJSONs = [:]
        
        while !container.isAtEnd {
            if let value = try? container.decode(AddChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(DeleteChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(UpdateChange.self) {
                changes.append(value)
            }
        }
    }
    
    /// Registers `change` to `self`
    func add(_ change: Change) {
        changes.append(change)
    }
    
    /// Stores the script and returns its stored index
    func store(script: JSScript) -> Int {
        let count = scripts.count
        scripts[count] = script
        return count
    }
    
    /// Stores the jsonValue and returns stored index
    func store(jsonValue: JSONValue) -> Int {
        let count = jsonValues.count
        jsonValues[count] = jsonValue
        return count
    }
    
    /// For every compare between two models of different versions, this function is called to register potentially updated json representation of an object
    func store(rhs: TypeInformation, encoderConfiguration: EncoderConfiguration) {
        let propertyTargets = [ObjectTarget.property, .necessity].map { $0.rawValue }
        if changes.contains(where: { $0.breaking && $0.element.isObject && $0.elementID == rhs.deltaIdentifier && propertyTargets.contains($0.element.target) }) {
            objectJSONs[rhs.typeName.name] = .init(JSONStringBuilder.jsonString(rhs, with: encoderConfiguration))
        }
    }
    
    func typeRenames() -> [UpdateChange] {
        guard compareConfiguration?.allowTypeRename == true else {
            return []
        }
        
        return changes.filter { $0.type == .rename && $0.element.target == ObjectTarget.typeName.rawValue } as? [UpdateChange] ?? []
    }
    
    func typesAreRenamings(lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        typeRenames().contains(where: { rename in
            if case let .stringValue(lhsName) = rename.from, case let .stringValue(rhsName) = rename.to {
                return lhsName == lhs.deltaIdentifier.rawValue && rhsName == rhs.deltaIdentifier.rawValue
            }
            return false
        })
    }
}
