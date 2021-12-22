//
// Created by Andreas Bauer on 22.12.21.
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
