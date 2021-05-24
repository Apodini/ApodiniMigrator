//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct EndpointComparator: Comparator {
    let lhs: Endpoint
    let rhs: Endpoint
    var changes: ChangeContainer
    
    var element: ChangeElement {
        .endpoint(lhs.deltaIdentifier)
    }
    
    init(lhs: Endpoint, rhs: Endpoint, changes: ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    func compare() {
        if lhs.absolutePath != rhs.absolutePath {
            changes.add(ValueChange(element: element, target: .path, from: .string(lhs.absolutePath.description), to: .string(rhs.absolutePath.description)))
        }
        
        if lhs.operation != rhs.operation {
            changes.add(ValueChange(element: element, target: .operation, from: .string(lhs.operation.rawValue), to: .string(lhs.operation.rawValue)))
        }
        
        let parametersComparator = ParametersComparator(lhs: lhs, rhs: rhs, changes: changes)
        parametersComparator.compare()
        
        let responseComparator = TypeInformationComparator(lhs: lhs.response, rhs: rhs.response, changes: changes)
        responseComparator.compare()
        
    }
}
