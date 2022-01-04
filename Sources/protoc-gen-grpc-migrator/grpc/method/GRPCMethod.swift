//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary
import ApodiniMigrator

class GRPCMethod: GRPCMethodRepresentable, GRPCMethodRenderable {
    private unowned let service: GRPCService
    private let method: MethodDescriptor
    var apodiniIdentifiers: GRPCMethodApodiniAnnotations

    // we track the content of all `update` EndpointChanges here
    private var endpointUpdates: [EndpointChange.UpdateChange] = []

    var methodName: String {
        method.name
    }

    var unavailable = false

    var sourceCodeComments: String? {
        method.protoSourceComments()
    }

    var methodPath: String {
        "\(service.servicePath)/\(method.name)"
    }

    var streamingType: StreamingType {
        switch (method.proto.clientStreaming, method.proto.serverStreaming) {
        case (true, true):
            return .bidirectionalStreaming
        case (true, false):
            return .clientStreaming
        case (false, true):
            return .serverStreaming
        case (false, false):
            return .unary
        }
    }

    var inputMessageName: String {
        service.protobufNamer.fullName(message: method.inputType)
    }

    var outputMessageName: String {
        service.protobufNamer.fullName(message: method.outputType)
    }

    init(_ method: MethodDescriptor, locatedIn service: GRPCService) {
        self.service = service
        self.method = method

        self.apodiniIdentifiers = .init(of: method)
    }

    func registerUpdateChange(_ change: EndpointChange.UpdateChange) {
        self.endpointUpdates.append(change)
    }
}
