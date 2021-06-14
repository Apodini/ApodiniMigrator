//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct AddChange: Change, Value {
    let element: ChangeElement
    let type: ChangeType
    
    let added: ChangeValue
    let defaultValue: ChangeValue
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        added: ChangeValue,
        defaultValue: ChangeValue,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.added = added
        self.defaultValue = defaultValue
        self.breaking = breaking
        self.solvable = solvable
        type = .addition
    }
}
