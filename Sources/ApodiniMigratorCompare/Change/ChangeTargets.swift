//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

public enum EndpointTarget: String, Value {
    case `self`
    case queryParameter
    case pathParameter
    case contentParameter
    case headerParameter
    case path
    case operation
    case errors
    case response
    
    static func target(for parameter: Parameter) -> EndpointTarget {
        switch parameter.parameterType {
        case .lightweight: return .queryParameter
        case .content: return .contentParameter
        case .path: return .pathParameter
        case .header: return .headerParameter
        }
    }
}

public enum ObjectTarget: String, Value {
    case `self`
    case typeName
    case property
    case propertyOptionality
}

public enum EnumTarget: String, Value {
    case `self`
    case `case`
    case caseRawValue
    case rawValueType
    case typeName
}

public enum NetworkingTarget: String, Value {
    case serverPath
    case version
    case encoderConfiguration
    case decoderConfiguration
}
