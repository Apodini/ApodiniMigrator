//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

public enum ChangeTarget: String, Value {
    case `self`
    case `case`
    case caseRawValue
    case rawValueType
    case typeName
    case property
    case propertyOptionality
    case queryParameter
    case pathParameter
    case contentParameter
    case headerParameter
    case path
    case operation
    case errors
    case response
    case serverPath
    case version
    case encoderConfiguration
    case decoderConfiguration
    
    static var endpointTargets: [ChangeTarget] {
        [.`self`, .queryParameter, .pathParameter, .contentParameter, .headerParameter, .path, .operation, .errors, .response]
    }
    
    static var objectTargets: [ChangeTarget] {
        [.`self`, .property, .propertyOptionality, .typeName]
    }
    
    static var enumTargets: [ChangeTarget] {
        [.`self`, .`case`, .caseRawValue ,.rawValueType, .typeName]
    }
    
    static var networkingTargets: [ChangeTarget] {
        [.serverPath, .version, .encoderConfiguration, .decoderConfiguration]
    }
    
    static func target(for parameter: Parameter) -> ChangeTarget {
        switch parameter.parameterType {
        case .lightweight: return .queryParameter
        case .content: return .contentParameter
        case .path: return .pathParameter
        case .header: return .headerParameter
        }
    }
}
