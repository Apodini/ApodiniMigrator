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
    var configuration: EncoderConfiguration
    
    var element: ChangeElement {
        .for(endpoint: lhs)
    }
    
    init(lhs: Endpoint, rhs: Endpoint, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
    }
    
    func compare() {
        if lhs.path != rhs.path { // Comparing resourcePaths
            changes.add(
                ValueChange(
                    element: element,
                    target: .path,
                    from: .string(lhs.path.resourcePath),
                    to: .string(rhs.path.resourcePath),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        if lhs.operation != rhs.operation {
            changes.add(
                ValueChange(
                    element: element,
                    target: .operation,
                    from: .string(lhs.operation.rawValue),
                    to: .string(lhs.operation.rawValue),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        var parametersComparator = ParametersComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        parametersComparator.compare()
        
        let responseComparator = TypeInformationComparator(lhs: lhs.response, rhs: rhs.response, changes: changes, configuration: configuration)
        responseComparator.compare()
    }
}
