//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobufPluginLibrary

class ApodiniGrpcMethod: SomeGRPCMethod {
    let endpoint: Endpoint
    let migration: MigrationContext
    var namer: SwiftProtobufNamer

    var deltaIdentifier: DeltaIdentifier {
        endpoint.deltaIdentifier
    }
    
    var updatedPackageName: String {
        migration.rhsExporterConfiguration.packageName
    }
    var serviceName: String
    var methodName: String

    var streamingType: StreamingType

    var inputMessageName: String
    var outputMessageName: String

    var sourceCodeComments: String?

    var unavailable = false
    var identifierChanges: [ElementIdentifierChange] = []
    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)?
    var parameterChange: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, conversionWarning: String?)?
    var responseChange: (from: TypeInformation, to: TypeInformation, backwardsMigration: Int, migrationWarning: String?)?

    init(_ endpoint: Endpoint, context: ProtoFileContext, migration: MigrationContext) {
        self.endpoint = endpoint
        self.migration = migration
        self.namer = context.namer

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
