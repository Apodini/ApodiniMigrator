//
//  DefaultEndpointInput.swift
//  
//
//  Created by Eldi Cano on 27.06.21.
//

import Foundation

/// Distinct case of default input of endpoint methods
enum DefaultEndpointInput: String, CaseIterable, Hashable {
    /// Authorization
    case authorization
    /// HTTP headers
    case httpHeaders
    
    /// String representation of `self` in endpoint method signature
    var signature: String {
        switch self {
        case .authorization: return "\(rawValue): String? = nil"
        case .httpHeaders: return "\(rawValue): HTTPHeaders = [:]"
        }
    }
    
    /// `self` as a key-value pair, e.g. `authorization: authorization`. Variable used inside of API file methods
    var keyValue: String {
        "\(rawValue): \(rawValue)"
    }
}
