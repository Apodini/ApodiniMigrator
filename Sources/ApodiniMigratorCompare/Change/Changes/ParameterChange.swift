//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation


enum ParameterChangeTarget: String, Value {
    case necessity
    case kind
    case typeInformation = "type"
}

struct ParameterChange: Change, Value {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    
    let identifier: DeltaIdentifier
    
    let parameterTarget: ParameterChangeTarget
    
    let from: ChangeValue
    let to: ChangeValue
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        identifier: DeltaIdentifier,
        parameterTarget: ParameterChangeTarget,
        from: ChangeValue,
        to: ChangeValue,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.target = target
        self.identifier = identifier
        self.parameterTarget = parameterTarget
        self.from = from
        self.to = to
        self.breaking = breaking
        self.solvable = solvable
        type = .parameterChange
    }
}
