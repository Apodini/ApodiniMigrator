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
    unowned let service: GRPCService
    private let method: MethodDescriptor
    var apodiniIdentifiers: GRPCMethodApodiniAnnotations

    var migration: MigrationContext {
        service.file.migration
    }

    // we track the content of all `update` EndpointChanges here
    var identifierChanges: [ElementIdentifierChange] = []
    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)?
    var parameterChange: ( // TODO support generating this change!
        from: TypeInformation,
        to: TypeInformation,
        forwardMigration: Int,
        conversionWarning: String?
    )?
    var responseChange: (
        from: TypeInformation,
        to: TypeInformation,
        backwardsMigration: Int,
        migrationWarning: String?
    )?

    var methodName: String
    var serviceName: String

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

    var sourceCodeComments: String?

    var streamingType: StreamingType

    var inputMessageName: String
    // In grpc all parameters are combined into a single parameter.
    // Typically, this means all parameter updates are mapped to property updates of a newly introduced wrapper type.
    // However, this wrapper type is not introduced if the endpoint already has a single message-based parameter (which is not optional).
    // In those cases we want to handle a single parameter update for the single parameter.
    var processedParameterUpdateAlready = false

    var outputMessageName: String

    var updatedOutputMessageName: String? {
        guard let change = responseChange else {
            return nil
        }

        return change.to.swiftType(namer: service.protobufNamer)
    }

    init(_ method: MethodDescriptor, locatedIn service: GRPCService) {
        self.service = service
        self.method = method
        self.apodiniIdentifiers = .init(of: method)

        self.methodName = method.name
        self.serviceName = service.servicePath

        self.sourceCodeComments = method.protoSourceComments()

        switch (method.proto.clientStreaming, method.proto.serverStreaming) {
        case (true, true):
            self.streamingType = .bidirectionalStreaming
        case (true, false):
            self.streamingType = .clientStreaming
        case (false, true):
            self.streamingType = .serverStreaming
        case (false, false):
            self.streamingType = .unary
        }

        self.inputMessageName = service.protobufNamer.fullName(message: method.inputType)
        self.outputMessageName = service.protobufNamer.fullName(message: method.outputType)
    }

    func registerUpdateChange(_ change: EndpointChange.UpdateChange) {
        precondition(apodiniIdentifiers.deltaIdentifier == change.id)

        switch change.updated {
        case let .identifier(identifier):
            self.identifierChanges.append(identifier)
        case let .communicationPattern(from, to):
            self.communicationPatternChange = (from, to)
        case let .response(from, to, backwardsMigration, migrationWarning):
            self.responseChange = (
                migration.typeStore.construct(from: from),
                migration.typeStore.construct(from: to),
                backwardsMigration,
                migrationWarning
            )
        case let .parameter(parameter):
            if case .idChange = parameter { // we ignore parameter renames!
                break
            }

            guard let parameterUpdate = parameter.modeledUpdateChange else {
                fatalError("Encountered parameter change for grpc method \(methodPath) which wasn't mapped to a property update: \(change)")
            }

            precondition(!processedParameterUpdateAlready, "Encountered multiple parameter updates for \(methodPath) with single parameter!")
            processedParameterUpdateAlready = true
            // TODO we must still handle that for single parameter endpoints!

            switch parameterUpdate.updated {
            case .parameterType:
                break // parameter type is ignored
            case .necessity:
                fatalError("Encountered unsupported parameter update for \(methodPath): \(parameterUpdate)")
                // TODO support necessity changes?
            case let .type(from, to, forwardMigration, migrationWarning):
                self.parameterChange = (
                    migration.typeStore.construct(from: from),
                    migration.typeStore.construct(from: to),
                    forwardMigration,
                    migrationWarning
                )
            }
        }
    }
}
