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

class ProtoGRPCMethod: SomeGRPCMethod {
    private unowned let service: GRPCService
    private let method: MethodDescriptor
    var apodiniIdentifiers: GRPCMethodApodiniAnnotations

    // we track the content of all `update` EndpointChanges here
    var identifierChanges: [EndpointIdentifierChange] = []
    var communicationPatternChange: (from: CommunicationalPattern, to: CommunicationalPattern)?
    var responseChangeChange: (
        from: TypeInformation,
        to: TypeInformation,
        backwardsMigration: Int,
        migrationWarning: String?
    )?

    var methodName: String {
        method.name
    }

    var serviceName: String {
        service.servicePath
    }

    var updatedMethodName: String? {
        for change in identifierChanges {
            // we ignore addition and removal change (assumption is, as long as there is a grpc
            // exporter, all endpoints have service name and rpc method identifiers!)
            guard change.id.rawValue == GRPCMethodName.identifierType,
                  let update = change.modeledUpdateChange else {
                continue
            }

            precondition(update.updated.from.value == methodName)
            return update.updated.to.value
        }

        return nil
    }

    var updatedServiceName: String? {
        for change in identifierChanges {
            // we ignore addition and removal change (assumption is, as long as there is a grpc
            // exporter, all endpoints have service name and rpc method identifiers!)
            guard change.id.rawValue == GRPCServiceName.identifierType,
                  let update = change.modeledUpdateChange else {
                continue
            }

            precondition(update.updated.from.value == serviceName)
            return update.updated.to.value
        }

        return nil
    }

    var unavailable = false

    var sourceCodeComments: String? {
        method.protoSourceComments()
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
        precondition(apodiniIdentifiers.deltaIdentifier == change.id)

        switch change.updated {
        case let .identifier(identifier):
            self.identifierChanges.append(identifier)
        case let .communicationalPattern(from, to):
            self.communicationPatternChange = (from, to)
        case let .response(from, to, backwardsMigration, migrationWarning):
            self.responseChangeChange = (from, to, backwardsMigration, migrationWarning)
        default:
            print("Ignoring change for now: \(change.updated)") // TODO handle .parameter
        }
    }
}
