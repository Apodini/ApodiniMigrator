//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

class ChangeContainer: Value {
    private var additions: [AddChange]
    private var deletions: [DeleteChange]
    private var renamings: [RenameChange]
    private var valueChanges: [ValueChange]
    private var parameterChanges: [ParameterChange]
    private var typeChanges: [TypeChange]
    
    init() {
        self.additions = []
        self.deletions = []
        self.renamings = []
        self.valueChanges = []
        self.parameterChanges = []
        self.typeChanges = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try additions.forEach( { try container.encode($0) })
        try deletions.forEach( { try container.encode($0) })
        try renamings.forEach( { try container.encode($0) })
        try valueChanges.forEach( { try container.encode($0) })
        try parameterChanges.forEach( { try container.encode($0) })
        try typeChanges.forEach( { try container.encode($0) })
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var additions: [AddChange] = []
        var deletions: [DeleteChange] = []
        var renamings: [RenameChange] = []
        var valueChanges: [ValueChange] = []
        var parameterChanges: [ParameterChange] = []
        var typeChanges: [TypeChange] = []
        
        while !container.isAtEnd {
            if let value = try? container.decode(AddChange.self) {
                additions.append(value)
            }
            
            if let value = try? container.decode(DeleteChange.self) {
                deletions.append(value)
            }
            
            if let value = try? container.decode(RenameChange.self) {
                renamings.append(value)
            }
            
            if let value = try? container.decode(ValueChange.self) {
                valueChanges.append(value)
            }
            
            if let value = try? container.decode(ParameterChange.self) {
                parameterChanges.append(value)
            }
            
            if let value = try? container.decode(TypeChange.self) {
                typeChanges.append(value)
            }
        }
        
        self.additions = additions
        self.deletions = deletions
        self.renamings = renamings
        self.valueChanges = valueChanges
        self.parameterChanges = parameterChanges
        self.typeChanges = typeChanges
    }
    
    func add(_ change: AddChange) {
        additions.append(change)
    }
    
    func add(_ change: DeleteChange) {
        deletions.append(change)
    }
    
    func add(_ change: RenameChange) {
        renamings.append(change)
        print(json)
    }
    
    func add(_ change: ValueChange) {
        valueChanges.append(change)
    }
    
    func add(_ change: ParameterChange) {
        parameterChanges.append(change)
    }
    
    func add(_ change: TypeChange) {
        typeChanges.append(change)
    }
    
    static func == (lhs: ChangeContainer, rhs: ChangeContainer) -> Bool {
        true // TODO
    }
    
    func hash(into hasher: inout Hasher) {
        // TODO
    }
}
