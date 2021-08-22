//
//  ServiceType.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public enum ServiceType: String, Value {
    case rest = "REST"
    case graphQL = "GraphQL"
    case gRPC
}
