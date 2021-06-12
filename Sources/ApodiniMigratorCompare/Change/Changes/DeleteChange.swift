//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct DeleteChange: Change, Value {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    
    let deleted: ChangeValue
    let fallbackValue: ChangeValue
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        deleted: ChangeValue,
        fallbackValue: ChangeValue,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.target = target
        self.deleted = deleted
        self.fallbackValue = fallbackValue
        self.breaking = breaking
        self.solvable = solvable
        type = .deletion
    }
}
