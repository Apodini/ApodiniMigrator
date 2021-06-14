//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct RenameChange: Change, Value {
    let element: ChangeElement
    let type: ChangeType
    
    let from: String
    let to: String
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        from: String,
        to: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.from = from
        self.to = to
        self.breaking = breaking
        self.solvable = solvable
        type = .rename
    }
}
