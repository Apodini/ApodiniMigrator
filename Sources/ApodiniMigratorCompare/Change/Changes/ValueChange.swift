//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct ValueChange: Change, Value {
    var element: ChangeElement
    var target: ChangeTarget
    let type: ChangeType
    
    var from: ChangeValue
    var to: ChangeValue
    
    init(element: ChangeElement, target: ChangeTarget, from: ChangeValue, to: ChangeValue) {
        self.element = element
        self.target = target
        self.from = from
        self.to = to
        type = .valueChange
    }
}
