//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct RenameChange: Change, Value {
    var element: ChangeElement
    var target: ChangeTarget
    let type: ChangeType
    
    var from: String
    var to: String
    
    init(element: ChangeElement, target: ChangeTarget, from: String, to: String) {
        self.element = element
        self.target = target
        self.from = from
        self.to = to
        type = .rename
    }
}