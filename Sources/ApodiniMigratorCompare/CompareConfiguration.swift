//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct CompareConfiguration: Value {
    private enum CodingKeys: String, CodingKey {
        case includeProviderSupport = "include-provider-support"
        case allowEndpointIdentifierUpdate = "allowed-endpoint-id-update"
        case allowTypeRename = "allowed-type-rename"
        case encoderConfiguration
    }
    
    let includeProviderSupport: Bool
    let allowEndpointIdentifierUpdate: Bool
    let allowTypeRename: Bool
    let encoderConfiguration: EncoderConfiguration
    
    public static var `default`: CompareConfiguration {
        .init(
            includeProviderSupport: false,
            allowEndpointIdentifierUpdate: false,
            allowTypeRename: false,
            encoderConfiguration: .default
        )
    }
    
    public static var active: CompareConfiguration {
        .init(
            includeProviderSupport: true,
            allowEndpointIdentifierUpdate: true,
            allowTypeRename: true,
            encoderConfiguration: .default
        )
    }
}
