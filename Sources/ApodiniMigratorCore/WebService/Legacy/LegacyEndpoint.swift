//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct LegacyEndpoint: Codable {
    let handlerName: String
    let deltaIdentifier: DeltaIdentifier
    let operation: Operation
    let path: EndpointPath
    let parameters: EndpointInput
    let response: TypeInformation
    let errors: [ErrorCode]
}

extension Endpoint {
    init(from endpoint: LegacyEndpoint) {
        self.handlerName = endpoint.handlerName
        self.deltaIdentifier = endpoint.deltaIdentifier
        self.identifiers = [:]
        self.communicationalPattern = .requestResponse
        self.parameters = endpoint.parameters
        self.response = endpoint.response
        self.errors = endpoint.errors

        self.add(identifier: endpoint.operation)
        self.add(identifier: endpoint.path)
    }
}
