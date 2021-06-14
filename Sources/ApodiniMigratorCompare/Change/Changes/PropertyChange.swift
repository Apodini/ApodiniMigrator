//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct PropertyChange: Change, Value {
    let element: ChangeElement
    let type: ChangeType
    
    let targetID: DeltaIdentifier?
    
    let from: TypeInformation
    let to: TypeInformation
    
    let convertTo: String
    let convertFrom: String
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        targetID: DeltaIdentifier,
        from: TypeInformation,
        to: TypeInformation,
        convertTo: String,
        convertFrom: String,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.targetID = targetID
        self.from = from
        self.to = to
        self.convertTo = convertTo
        self.convertFrom = convertFrom
        self.breaking = breaking
        self.solvable = solvable
        type = .propertyChange
    }
}
