//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

/// A container reference object to register changes during comparison of documents of two versions.
/// Used internally in the migration guide generation to be passed in the DocumentComparator. Furthermore
/// handles the logic of encoding and decoding different change types
final class ChangeContainer: Codable {
    /// Changes of the container
    private(set) var changes: [Change]
    /// Compare config passed from migration guide, property is owned by the migration guide, and does not get encoded or decoded from `self`
    var compareConfiguration: CompareConfiguration?
    
    /// Initializes `self` with empty changes
    init(compareConfiguration: CompareConfiguration? = nil) {
        changes = []
        self.compareConfiguration = compareConfiguration
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
    
    func propertyRenames(of type: TypeInformation) -> [UpdateChange] {
        changes.filter {
            $0.type == .rename
            && $0.element.isObject
                && $0.elementID == type.deltaIdentifier
                && $0.element.target == ObjectTarget.property.rawValue
        } as? [UpdateChange] ?? []
    }
}
