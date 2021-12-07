//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct EndpointComparator: Comparator {
    let lhs: Endpoint
    let rhs: Endpoint
    let changes: ChangeContextNode
    var configuration: EncoderConfiguration
    
    func compare() {
        func element(_ target: EndpointTarget) -> ChangeElement {
            .for(endpoint: lhs, target: target)
        }

        if lhs.identifier(for: EndpointPath.self) != rhs.identifier(for: EndpointPath.self) { // Comparing resourcePaths
            let pathChange: EndpointChange = .update(
                id: lhs.deltaIdentifier,
                updated: .identifier(
                    type: .path,
                    from: lhs.identifier(for: EndpointPath.self),
                    to: rhs.identifier(for: EndpointPath.self)
                )
            )
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
            let operationChange: EndpointChange = .update(
                id: lhs.deltaIdentifier,
                updated: .identifier(
                    type: .operation,
                    from: lhs.identifier(for: EndpointPath.self),
                    to: rhs.identifier(for: EndpointPath.self)
                )
            )
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

        // TODO the parameter changes must be encapsulated into a endpoint change!
        let parametersComparator = ParametersComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        parametersComparator.compare()
        
        let lhsResponse = lhs.response
        let rhsResponse = rhs.response
        
        if typesNeedConvert(lhs: lhsResponse, rhs: rhsResponse) {
            let jsScriptBuilder = JSScriptBuilder(from: lhsResponse, to: rhsResponse, changes: changes, encoderConfiguration: configuration)
            let responseChange: EndpointChange = .update(
                id: lhs.deltaIdentifier,
                updated: .response(
                    from: lhs.response.referenced(),
                    to: rhs.response.referenced(),
                    backwardsConversion: changes.store(script: jsScriptBuilder.convertToFrom),
                    conversionWarning: jsScriptBuilder.hint
                )
            )
            changes.add(
                UpdateChange(
                    element: element(.response),
                    from: .element(lhs.response.referenced()),
                    to: .element(rhs.response.referenced()),
                    convertToFrom: changes.store(script: jsScriptBuilder.convertToFrom),
                    convertionWarning: jsScriptBuilder.hint,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
