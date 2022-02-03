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

        precondition(endpoint.parameters.count == 1, "Received unexpected endpoint state for \(endpoint.handlerName) with multiple parameters: \(endpoint.parameters)")
        let endpointInput = endpoint.parameters.first! // swiftlint:disable:this force_unwrapping

        // TODO packageName?
        self.inputMessageName = endpointInput.typeInformation.swiftType(namer: context.namer)

        // TODO packageName?
        self.outputMessageName = endpoint.response.swiftType(namer: context.namer)
    }
}
