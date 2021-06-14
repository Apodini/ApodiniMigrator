//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

class ChangeContainer: Value {
    var changes: [Change]
    
    init() {
        changes = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        for change in changes {
            if let change = change as? AddChange {
                try container.encode(change)
            }
            
            if let change = change as? DeleteChange {
                try container.encode(change)
            }
            
            if let change = change as? RenameChange {
                try container.encode(change)
            }
            
            if let change = change as? UpdateChange {
                try container.encode(change)
            }
            
            if let change = change as? ParameterChange {
                try container.encode(change)
            }
            
            if let change = change as? PropertyChange {
                try container.encode(change)
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.changes = []
        
        while !container.isAtEnd {
            if let value = try? container.decode(AddChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(DeleteChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(RenameChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(UpdateChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(ParameterChange.self) {
                changes.append(value)
            }
            
            if let value = try? container.decode(PropertyChange.self) {
                changes.append(value)
            }
        }
    }
    
    func add(_ change: Change) {
        changes.append(change)
    }
    
    static func == (lhs: ChangeContainer, rhs: ChangeContainer) -> Bool {
        true // TODO
    }
    
    func hash(into hasher: inout Hasher) {
        // TODO
    }
}
