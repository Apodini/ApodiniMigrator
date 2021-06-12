//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

// TODO Review
struct TypeChange: Change, Value {
    let element: ChangeElement
    let target: ChangeTarget
    let type: ChangeType
    
    let identifier: DeltaIdentifier
    
    let from: TypeInformation
    let to: TypeInformation
    
    let breaking: Bool
    let solvable: Bool
    
    init(
        element: ChangeElement,
        target: ChangeTarget,
        identifier: DeltaIdentifier,
        from: TypeInformation,
        to: TypeInformation,
        breaking: Bool,
        solvable: Bool
    ) {
        self.element = element
        self.target = target
        self.identifier = identifier
        self.from = from
        self.to = to
        self.breaking = breaking
        self.solvable = solvable
        type = .typeChange
    }
    
    func convertTo() -> String {
        "" // Some js function to convert from to
    }
    
    func convertFrom() -> String {
        "" // some js function to convert to from
    }
}
