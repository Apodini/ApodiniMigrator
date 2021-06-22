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
        
        if typesNeedConvert(lhs: lhsResponse, rhs: rhsResponse) {
            let jsConverter = JSScriptBuilder(from: lhsResponse, to: rhsResponse, changes: changes, encoderConfiguration: configuration)
            changes.add(
                UpdateChange(
                    element: element(.response),
                    from: .element(reference(lhs.response)),
                    to: .element(reference(rhs.response)),
                    convertToFrom: changes.store(script: jsConverter.convertToFrom),
                    convertionWarning: jsConverter.hint,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}