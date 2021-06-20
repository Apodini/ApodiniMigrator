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
    let changes: ChangeContainer
    var configuration: EncoderConfiguration
    
    func compare() {
        func element(_ target: EndpointTarget) -> ChangeElement {
            .for(endpoint: lhs, target: target)
        }
        
        if lhs.path != rhs.path { // Comparing resourcePaths
            changes.add(
                UpdateChange(
                    element: element(.resourcePath),
                    from: .element(lhs.path),
                    to: .element(rhs.path),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        if lhs.operation != rhs.operation {
            changes.add(
                UpdateChange(
                    element: element(.operation),
                    from: .element(lhs.operation),
                    to: .element(rhs.operation),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        let parametersComparator = ParametersComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        parametersComparator.compare()
        
        let lhsResponse = lhs.response
        let rhsResponse = rhs.response
        
        /// TODO request from change container whether the type has been renamed and check whether the name is not equal
        if !(lhsResponse.sameType(with: rhsResponse) && (lhsResponse ?= rhsResponse)) {
            let jsConverter = JSScriptBuilder(from: lhsResponse, to: rhsResponse, changes: changes)
            changes.add(
                UpdateChange(
                    element: element(.response),
                    from: .id(from: lhs.response),
                    to: .element(rhs.response),
                    convertTo: jsConverter.convertToFrom,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
