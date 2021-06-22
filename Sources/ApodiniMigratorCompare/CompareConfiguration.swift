//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
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
