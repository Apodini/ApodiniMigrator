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
    case property
    case queryParameter
    case pathParameter
    case contentParameter
    case headerParameter
    case path
    case operation
    case errors
    case serverPath
    case version
    case encoderConfiguration
    case decoderConfiguration
    
    static var enpointTargets: [ChangeTarget] {
        [.`self`, .queryParameter, .pathParameter, .contentParameter, .headerParameter, .path, .operation, .errors]
    }
    
    static var objectTargets: [ChangeTarget] {
        [.`self`, .property]
    }
    
    static var enumTargets: [ChangeTarget] {
        [.`self`, .case]
    }
    
    static var networkingTargets: [ChangeTarget] {
        [.serverPath, .version, .encoderConfiguration, .decoderConfiguration]
    }
}
