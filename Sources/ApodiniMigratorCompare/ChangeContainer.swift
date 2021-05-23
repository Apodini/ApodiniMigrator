//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct ChangeContainer {
    var additions: [AddChange]
    var deletions: [DeleteChange]
    var renamings: [RenameChange]
    var valueChanges: [ValueChange]
    var typeChanges: [TypeChange]
    
    
    init() {
        self.additions = []
        self.deletions = []
        self.renamings = []
        self.valueChanges = []
        self.typeChanges = []
    }
    
    mutating func add(_ change: AddChange) {
        additions.append(change)
    }
    
    mutating func add(_ change: DeleteChange) {
        deletions.append(change)
    }
    
    mutating func add(_ change: RenameChange) {
        renamings.append(change)
    }
    
    mutating func add(_ change: ValueChange) {
        valueChanges.append(change)
    }
    
    mutating func add(_ change: TypeChange) {
        typeChanges.append(change)
    }
}
