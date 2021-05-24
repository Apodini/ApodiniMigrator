//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct AddChange: Change, Value {
    var element: ChangeElement
    var target: ChangeTarget
    let type: ChangeType
    
    var added: ChangeValue
    var defaultValue: ChangeValue
    
    init(element: ChangeElement, target: ChangeTarget, added: ChangeValue, defaultValue: ChangeValue) {
        self.element = element
        self.target = target
        self.added = added
        self.defaultValue = defaultValue
        type = .addition
    }
}
