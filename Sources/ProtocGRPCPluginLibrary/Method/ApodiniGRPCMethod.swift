//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCore
import SwiftProtobufPluginLibrary

struct ApodiniGrpcMethod: SomeGRPCMethod {
    let endpoint: Endpoint

    var methodName: String
    var serviceName: String

    var streamingType: StreamingType

    var inputMessageName: String
    var outputMessageName: String

    var unavailable: Bool {
        false
    }

    var sourceCodeComments: String? {
        nil
    }

    init(_ endpoint: Endpoint, context: ProtoFileContext) {
        self.endpoint = endpoint

        self.methodName = endpoint.identifier(for: GRPCMethodName.self).rawValue
        self.serviceName = endpoint.identifier(for: GRPCServiceName.self).rawValue

        self.streamingType = StreamingType(from: endpoint.communicationPattern)

        if let endpointInput = endpoint.parameters.first {
            precondition(endpoint.parameters.count == 1, "Received unexpected endpoint state for \(endpoint.handlerName) with multiple parameters: \(endpoint.parameters)")
            self.inputMessageName = endpointInput.typeInformation.swiftType(namer: context.namer)
        } else {
            self.inputMessageName = TypeInformation.ProtoMagics.googleProtobufEmpty
        }

        self.outputMessageName = endpoint.response.swiftType(namer: context.namer)
    }
}
