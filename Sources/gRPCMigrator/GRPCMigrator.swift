//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import ApodiniMigratorCompare
import Logging

extension Placeholder {
    static var hostname: Placeholder {
        Placeholder("HOSTNAME")
    }

    static var port: Placeholder {
        Placeholder("PORT")
    }
}

public struct GRPCMigrator: Migrator {
    enum MigratorError: Error {
        case incompatible(message: String)
    }

    public var bundle: Bundle = .module

    public static let logger: Logger = {
        .init(label: "org.apodini.migrator.grpc")
    }()

    private let protoFilePath: Path
    private let protoFile: String

    private let document: APIDocument
    private let documentPath: String

    private let migrationGuide: MigrationGuide
    private let migrationGuidePath: String?

    private let httpServer: HTTPInformation

    public init(protoFile: String, documentPath: String, migrationGuidePath: String? = nil) throws {
        let path = Path(protoFile)

        self.document = try APIDocument.decode(from: Path(documentPath))
        self.documentPath = documentPath

        self.protoFile = path.lastComponent
        self.protoFilePath = Path(path.absolute().description.replacingOccurrences(of: path.lastComponent, with: ""))

        if let path = migrationGuidePath {
            try self.migrationGuide = MigrationGuide.decode(from: Path(path))
            self.migrationGuidePath = migrationGuidePath
        } else {
            self.migrationGuide = .empty(id: document.id)
            self.migrationGuidePath = nil
        }

        guard migrationGuide.id == document.id else {
            throw MigratorError.incompatible(
                message: """
                         Migration guide is not compatible with the provided document. Apparently another old document version, \
                         has been used to generate the migration guide!
                         """
            )
        }

        guard document.serviceInformation.exporterIfPresent(for: GRPCExporterConfiguration.self, migrationGuide: migrationGuide) != nil else {
            throw MigratorError.incompatible(
                message: """
                         GRPCMigrator is not compatible with the provided documents. The web service either \
                         hasn't a GRPC interface configured, or it was removed in the latest version!
                         """
            )
        }

        var httpInformation = document.serviceInformation.http
        for change in migrationGuide.serviceChanges {
            if let update = change.modeledUpdateChange,
               case let .http(_, to) = update.updated {
                httpInformation = to
            }
        }
        self.httpServer = httpInformation
    }

    public var library: RootDirectory {
        Sources {
            Target(.packageName) {
                ProtocGenerator(
                    pluginName: "grpc-migrator",
                    protoPath: protoFilePath.description,
                    protoFile: protoFile,
                    options: [
                        "Visibility": "Public",
                        "MigrationGuide": migrationGuidePath ?? "", // empty as migrationGuide might be nil
                        "APIDocument": documentPath
                    ],
                    environment: [
                        // TODO control!
                        "PROTOC_GEN_GRPC_DUMP": "./dump.binary"
                    ]
                )

                Directory("Networking") {
                    ResourceFile(copy: "GRPCNetworking.swift")
                        .replacing(.hostname, with: httpServer.hostname)
                        .replacing(.port, with: httpServer.port.description) // TODO this is wrong?
                    ResourceFile(copy: "GRPCNetworkingError.swift")
                    ResourceFile(copy: "GRPCResponseStream.swift")
                }

                Directory("Utils") {
                    ResourceFile(copy: "Utils.swift")
                    ResourceFile(copy: "Google_Protobuf_Timestamp+Codable.swift")
                }

                Directory("Resources") {
                    StringFile(name: "js-convert-scripts.json", content: migrationGuide.scripts.json)
                    StringFile(name: "json-values.json", content: migrationGuide.jsonValues.json)
                }
            }
                .dependency(product: "GRPC", of: "grpc-swift")
                .dependency(product: "ApodiniMigratorClientSupport", of: "ApodiniMigrator")
                .resource(type: .process, path: "Resources")
        }

        SwiftPackageFile(swiftTools: "5.5")
            .platform(".macOS(.v12)", ".iOS(.v15)") // async-await support is annotated with availability, therefore v12 requirement
            .dependency(url: "https://github.com/grpc/grpc-swift.git", ".exact(\"1.6.0-async-await.1\")")
            .dependency(url: "https://github.com/Apodini/ApodiniMigrator.git", ".upToNextMinor(from: \"0.2.0\")")
            .product(library: .packageName, targets: .packageName)


        ReadMeFile()
    }
}
