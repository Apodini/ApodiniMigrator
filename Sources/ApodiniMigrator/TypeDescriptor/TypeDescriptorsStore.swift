//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.05.21.
//

import Foundation

typealias TypesSet = Set<TypeDescriptor>

struct TypeDescriptorsStore {
    var responses: TypesSet
    var parameters: [ParameterType: TypesSet]
    
    mutating func storeResponse(_ response: TypeDescriptor) -> TypeDescriptor { /// dereference
        responses += response
        return response
    }
    
    mutating func storeParamater(_ parameter: TypeDescriptor, type: ParameterType) -> TypeDescriptor {
        if parameters[type] == nil {
            parameters[type] = []
        }
        
        parameters[type]?.insert(parameter)
        return parameter
    }
}
