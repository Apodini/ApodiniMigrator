//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct AddChange: Change, Value {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    
    let added: ChangeValue
    let defaultValue: ChangeValue
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        added: ChangeValue,
        defaultValue: ChangeValue,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.target = target
        self.added = added
        self.defaultValue = defaultValue
        self.breaking = breaking
        self.solvable = solvable
        type = .addition
    }
}
