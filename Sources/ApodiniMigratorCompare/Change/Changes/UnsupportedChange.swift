//
//  File.swift
//  
//
//  Created by Eldi Cano on 14.06.21.
//

import Foundation

struct UnsupportedChange: Change {
    let element: ChangeElement
    let type: ChangeType
    let breaking: Bool
    let solvable: Bool
    let description: String
    
    init(
        element: ChangeElement,
        breaking: Bool,
        solvable: Bool,
        description: String
    ) {
        self.element = element
        self.breaking = breaking
        self.solvable = solvable
        self.description = description
        type = .unsupported
    }
}
