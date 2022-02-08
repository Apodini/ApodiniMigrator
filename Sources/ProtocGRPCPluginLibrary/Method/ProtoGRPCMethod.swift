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

    var deltaIdentifier: DeltaIdentifier {
        apodiniIdentifiers.deltaIdentifier
    }

    var migration: MigrationContext {
        service.file.migration
    }

    var namer: SwiftProtobufNamer {
        service.protobufNamer
    }

    var unavailable = false
    // we track the content of all `update` EndpointChanges here
    var identifierChanges: [ElementIdentifierChange] = []
    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)?
    var parameterChange: (
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

    var streamingType: StreamingType

    var inputMessageName: String
    var outputMessageName: String

    var sourceCodeComments: String?

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
}
