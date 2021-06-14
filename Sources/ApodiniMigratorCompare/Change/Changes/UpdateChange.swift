//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct UpdateChange: Change, Value {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    
    let from: ChangeValue
    let to: ChangeValue
    
    let targetID: DeltaIdentifier?
    
    let breaking: Bool
    let solvable: Bool
    
    let convertFunction: String?
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        from: ChangeValue,
        to: ChangeValue,
        targetID: DeltaIdentifier? = nil,
        convertFunction: String? = nil,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.target = target
        self.from = from
        self.to = to
        self.targetID = targetID
        self.convertFunction = convertFunction
        self.breaking = breaking
        self.solvable = solvable
        type = .update
    }
}
