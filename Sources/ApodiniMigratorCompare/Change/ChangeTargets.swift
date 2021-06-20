//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

/// Distinct cases of endpoint targets that are subject to change
public enum EndpointTarget: String, Value {
    /// Indicates a change that relates to the endpoint itself, e.g. a deleted or added endpoint, or update of the id
    case `self`
    /// Query parameter target
    case queryParameter = "query-parameter"
    /// Path parameter target
    case pathParameter = "path-parameter"
    /// Content parameter target
    case contentParameter = "content-parameter"
    /// Header parameter target
    case headerParameter = "header-parameter"
    /// Path target
    case resourcePath = "resource-path"
    /// Operation target
    case operation = "http-method"
    /// Errors target
    case errors
    /// Response target
    case response
    
    /// An internal convenience static method to return the corresponding `EndpointTarget` of a parameter
    static func target(for parameter: Parameter) -> EndpointTarget {
        switch parameter.parameterType {
        case .lightweight: return .queryParameter
        case .content: return .contentParameter
        case .path: return .pathParameter
        case .header: return .headerParameter
        }
    }
}

/// Distinct cases of object targets that are subject to change
public enum ObjectTarget: String, Value {
    /// Indicates a change that relates to the object itself, e.g. a deleted or added object
    case `self`
    /// TypeName target
    case typeName = "type-name"
    /// Property target
    case property
    /// Property optionality target
    case propertyOptionality = "property-optionality"
}

/// Distinct cases of enum targets that are subject to change
public enum EnumTarget: String, Value {
    /// Indicates a change that relates to the enum itself, e.g. a deleted or added enum
    case `self`
    /// TypeName target
    case typeName = "type-name"
    /// Case target
    case `case`
    /// Case raw value target
    case caseRawValue = "raw-value"
    /// RawValue type target
    case rawValueType = "raw-value-type"
}

/// Distinct cases of networking service targets that are subject to change
public enum NetworkingTarget: String, Value {
    /// Server path target, including the version path component
    case serverPath = "base-url"
    /// Encoder configuration target
    case encoderConfiguration = "encoder"
    /// Decoder configuration target
    case decoderConfiguration = "decoder"
}
