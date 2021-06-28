//
//  CompareConfiguration.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public struct CompareConfiguration: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case includeProviderSupport = "include-provider-support"
        case allowEndpointIdentifierUpdate = "allowed-endpoint-id-update"
        case allowTypeRename = "allowed-type-rename"
    }
    
    let includeProviderSupport: Bool
    let allowEndpointIdentifierUpdate: Bool
    let allowTypeRename: Bool
    
    public static var `default`: CompareConfiguration {
        .init(
            includeProviderSupport: true,
            allowEndpointIdentifierUpdate: false,
            allowTypeRename: false
        )
    }
}
