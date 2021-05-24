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
    var element: ChangeElement
    var target: ChangeTarget
    let type: ChangeType
    
    var identifier: DeltaIdentifier
    
    var parameterTarget: ParameterChangeTarget
    
    var from: ChangeValue
    var to: ChangeValue
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        identifier: DeltaIdentifier,
        parameterTarget: ParameterChangeTarget,
        from: ChangeValue,
        to: ChangeValue
    ) {
        self.element = element
        self.target = target
        self.identifier = identifier
        self.parameterTarget = parameterTarget
        self.from = from
        self.to = to
        type = .parameterChange
    }
}
