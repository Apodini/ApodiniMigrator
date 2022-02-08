//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct LegacyCompareConfiguration: Decodable {
    private enum CodingKeys: String, CodingKey {
        case includeProviderSupport = "include-provider-support"
        case allowEndpointIdentifierUpdate = "allowed-endpoint-id-update"
        case allowTypeRename = "allowed-type-rename"
    }

    let includeProviderSupport: Bool
    let allowEndpointIdentifierUpdate: Bool
    let allowTypeRename: Bool
}

extension CompareConfiguration {
    init(from configuration: LegacyCompareConfiguration) {
        self.includeProviderSupport = configuration.includeProviderSupport
        self.allowEndpointIdentifierUpdate = configuration.allowEndpointIdentifierUpdate
        self.allowTypeRename = configuration.allowTypeRename
        self.encoderConfiguration = .default // best effort
    }
}
