//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct ParametersComparator: Comparator {
    let lhs: Endpoint
    let rhs: Endpoint
    var changes: ChangeContainer
    
    init(lhs: Endpoint, rhs: Endpoint, changes: inout ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    mutating func compare() {
        
    }
}

extension Endpoint {
    var queryParameters: EndpointInput {
        parameters.filter(.lightweight)
    }
    
    var headerParameters: EndpointInput {
        parameters.filter(.header)
    }
    
    var pathParameters: EndpointInput {
        parameters.filter(.path)
    }
    
    var contentParameter: Parameter? {
        parameters.filter(.content).first
    }
}

extension EndpointInput {
    func filter(_ parameterType: ParameterType) -> Self {
        filter { $0.parameterType == parameterType }
    }
}
