//
//  File.swift
//  
//
//  Created by Eldi Cano on 14.06.21.
//

import Foundation

struct UnsupportedChange: Change {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    let breaking: Bool
    let solvable: Bool
    let description: String
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        breaking: Bool,
        solvable: Bool,
        description: String
    ) {
        self.element = element
        self.target = target
        self.breaking = breaking
        self.solvable = solvable
        self.description = description
        type = .unsupported
    }
}
