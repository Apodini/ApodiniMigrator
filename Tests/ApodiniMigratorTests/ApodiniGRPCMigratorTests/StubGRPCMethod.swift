//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
@testable import ApodiniMigrator
@testable import gRPCMigrator
@testable import ProtocGRPCPluginLibrary
@testable import SwiftProtobufPluginLibrary
import ApodiniDocumentExport

class StubGRPCMethod: SomeGRPCMethod {
    let migration: ProtocGRPCPluginLibrary.MigrationContext
    let namer: SwiftProtobufPluginLibrary.SwiftProtobufNamer
    let deltaIdentifier: DeltaIdentifier
    
    let updatedPackageName: String
    let methodName: String
    let serviceName: String

    let streamingType: StreamingType
    let inputMessageName: String
    let outputMessageName: String

    let sourceCodeComments: String?

    var unavailable = false
    var identifierChanges: [ElementIdentifierChange] = []
    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)?
    var parameterChange: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, conversionWarning: String?)?
    var responseChange: (from: TypeInformation, to: TypeInformation, backwardsMigration: Int, migrationWarning: String?)?

    init(
        deltaIdentifier: DeltaIdentifier = "StubGRPCMethod",
        packageName: String = "package",
        serviceName: String = "service",
        methodName: String = "method",
        streamingType: StreamingType = .unary,
        inputMessageName: String = TypeInformation.ProtoMagics.googleProtobufEmpty,
        outputMessageName: String = TypeInformation.ProtoMagics.googleProtobufEmpty,
        sourceCodeComments: String? = nil
    ) {
        let document = APIDocument.mock()
        self.migration = MigrationContext(document: document, migrationGuide: .empty(id: document.id))
        self.namer = .mock()

        self.deltaIdentifier = deltaIdentifier
        self.updatedPackageName = packageName
        self.serviceName = serviceName
        self.methodName = methodName

        self.streamingType = streamingType

        self.inputMessageName = inputMessageName
        self.outputMessageName = outputMessageName

        self.sourceCodeComments = sourceCodeComments
    }
}

extension APIDocument {
    static func mock() -> APIDocument {
        let information = ServiceInformation(
            version: .default,
            http: .init(hostname: "localhost"),
            exporters: [
                GRPCExporterConfiguration(packageName: "TestPackage", serviceName: "TestService", pathPrefix: "apodini", reflectionEnabled: true)
            ]
        )

        return APIDocument(serviceInformation: information)
    }
}

extension SwiftProtobufNamer {
    static func mock() -> SwiftProtobufNamer {
        SwiftProtobufNamer(protoFileToModuleMappings: .init(), targetModule: "")
    }
}

extension ProtoFileContext {
    static func mock() -> ProtoFileContext {
        // swiftlint:disable:next force_try
        ProtoFileContext(namer: .mock(), options: try! .init(parameter: "APIDocument=\(Documents.v1_2.bundlePath.string)"), hasUnknownPreservingSemantics: true)
    }
}
