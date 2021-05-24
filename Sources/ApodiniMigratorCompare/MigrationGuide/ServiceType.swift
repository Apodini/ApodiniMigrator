//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation


/// service type stated in migration guide - currently REST only
enum ServiceType: String, Value {
    case rest = "REST"
    case graphQL = "GraphQL"
    case gRPC
}
