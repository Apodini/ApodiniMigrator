//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct DeleteChange: Change, Value {
    var element: ChangeElement
    var target: ChangeTarget
    let type: ChangeType
    
    var deleted: ChangeValue
    var fallbackValue: ChangeValue
    
    init(element: ChangeElement, target: ChangeTarget, deleted: ChangeValue, fallbackValue: ChangeValue) {
        self.element = element
        self.target = target
        self.deleted = deleted
        self.fallbackValue = fallbackValue
        type = .deletion
    }
    
}
