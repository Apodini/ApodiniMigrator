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
    case typeName
    case property
    case queryParameter
    case pathParameter
    case contentParameter
    case headerParameter
    case path
    case operation
    case errors
    case response // pass responses to types comparator, request result if response has some kind of convert changes (or endpoint file renderer, checks for
    // typeConvert changes where from is equal to old response and to is different (considering typeNames that were not involved in any renamings)
    case serverPath
    case version
    case encoderConfiguration
    case decoderConfiguration
    
    static var enpointTargets: [ChangeTarget] {
        [.`self`, .queryParameter, .pathParameter, .contentParameter, .headerParameter, .path, .operation, .errors, .response]
    }
    
    static var objectTargets: [ChangeTarget] {
        [.`self`, .property, .typeName]
    }
    
    static var enumTargets: [ChangeTarget] {
        [.`self`, .case, .typeName]
    }
    
    static var networkingTargets: [ChangeTarget] {
        [.serverPath, .version, .encoderConfiguration, .decoderConfiguration]
    }
}
