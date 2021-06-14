//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

// TODO Review
struct TypePropertyChange: Change, Value {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    
    let identifier: DeltaIdentifier
    
    let from: TypeInformation
    let to: TypeInformation
    
    let convertTo: String
    let convertFrom: String
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        identifier: DeltaIdentifier,
        from: TypeInformation,
        to: TypeInformation,
        convertTo: String,
        convertFrom: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.target = target
        self.identifier = identifier
        self.from = from
        self.to = to
        self.convertTo = convertTo
        self.convertFrom = convertFrom
        self.breaking = breaking
        self.solvable = solvable
        type = .typeChange
    }
}
