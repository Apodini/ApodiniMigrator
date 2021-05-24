//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

// TODO Review
struct TypeChange: Change, Value {
    var element: ChangeElement
    var target: ChangeTarget
    let type: ChangeType
    
    var identifier: DeltaIdentifier
    
    var from: TypeInformation
    var to: TypeInformation
    
    init(element: ChangeElement, target: ChangeTarget, identifier: DeltaIdentifier, from: TypeInformation, to: TypeInformation) {
        self.element = element
        self.target = target
        self.identifier = identifier
        self.from = from
        self.to = to
        type = .typeChange
    }
    
    func convertTo() -> String {
        "" // Some js function to convert from to
    }
    
    func convertFrom() -> String {
        "" // some js function to convert to from
    }
}
