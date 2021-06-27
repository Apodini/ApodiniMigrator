//
//  ServiceType.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

public enum ServiceType: String, Value {
    case rest = "REST"
    case graphQL = "GraphQL"
    case gRPC
}
