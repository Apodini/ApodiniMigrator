//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Logging
import ApodiniMigrator

extension Placeholder {
    static var serverPath: Placeholder {
        Placeholder("serverpath")
    }

    static var encoderConfiguration: Placeholder {
        Placeholder("encoder___configuration")
    }

    static var decoderConfiguration: Placeholder {
        Placeholder("decoder___configuration")
    }
}

public struct RESTMigrator: ApodiniMigrator.Migrator {
    enum MigratorError: Error {
        case incompatible(message: String)
    }

    public var bundle = Bundle.module

    public static let logger: Logger = {
        .init(label: "org.apodini.migrator.rest")
    }()

    private var document: APIDocument
    private var migrationGuide: MigrationGuide

    /// Networking migrator
    private let networkingMigrator: NetworkingMigrator

    @SharedNodeStorage
    var apiFileMigratedEndpoints: [MigratedEndpoint]

    public init(documentPath: String, migrationGuidePath: String? = nil) throws {
        try self.document = APIDocument.decode(from: Path(documentPath))

        if let path = migrationGuidePath {
            try self.migrationGuide = MigrationGuide.decode(from: Path(path))
        } else {
            self.migrationGuide = .empty(id: document.id)
        }

        guard migrationGuide.id == document.id else {
            throw MigratorError.incompatible(
                message: """
                         Migration guide is not compatible with the provided document. Apparently another old document version, \
                         has been used to generate the migration guide!
                         """
            )
        }

        guard document.serviceInformation.exporterIfPresent(for: RESTExporterConfiguration.self, migrationGuide: migrationGuide) != nil else {
            throw MigratorError.incompatible(
                message: """
                         RESTMigrator is not compatible with the provided documents. The web service either \
                         hasn't a REST interface configured, or it was removed in the latest version!
                         """
            )
        }

        networkingMigrator = NetworkingMigrator(
            baseServiceInformation: document.serviceInformation,
            serviceChanges: migrationGuide.serviceChanges
        )

        // combine multiple content parameters into a single content parameter
        document.applyEndpointParameterCombination(
            considering: &migrationGuide,
            using: RESTContentParameterCombination()
        )
    }

    public var library: RootDirectory {
        let encoderConfiguration = networkingMigrator.encoderConfiguration()
        let decoderConfiguration = networkingMigrator.decoderConfiguration()

        Sources {
            Target(.packageName) {
                Directory("Endpoints") {
                    EndpointsMigrator(
                        migratedEndpointsReference: $apiFileMigratedEndpoints,
                        document: document,
                        migrationGuide: migrationGuide
                    )
                }

                Directory("HTTP") {
                    ResourceFile(copy: "ApodiniError.swift", filePrefix: { FileHeaderComment() })
                    ResourceFile(copy: "HTTPAuthorization.swift", filePrefix: { FileHeaderComment() })
                    ResourceFile(copy: "HTTPHeaders.swift", filePrefix: { FileHeaderComment() })
                    ResourceFile(copy: "HTTPMethod.swift", filePrefix: { FileHeaderComment() })
                    ResourceFile(copy: "Parameters.swift", filePrefix: { FileHeaderComment() })
                }

                Directory("Models") {
                    ModelsMigrator(
                        document: document,
                        migrationGuide: migrationGuide
                    )
                }

                Directory("Networking") {
                    ResourceFile(copy: "Handler.swift", filePrefix: { FileHeaderComment() })
                    ResourceFile(copy: "NetworkingService.swift", filePrefix: { FileHeaderComment() })
                        .replacing(.serverPath, with: networkingMigrator.serverPath())
                        .replacing(.encoderConfiguration, with: encoderConfiguration.networkingDescription)
                        .replacing(.decoderConfiguration, with: decoderConfiguration.networkingDescription)
                }

                Directory("Resources") {
                    StringFile(name: "js-convert-scripts.json", content: migrationGuide.scripts.json)
                    StringFile(name: "json-values.json", content: migrationGuide.jsonValues.json)
                }

                Directory("Utils") {
                    ResourceFile(copy: "Utils.swift", filePrefix: { FileHeaderComment() })
                }

                APIFile($apiFileMigratedEndpoints)
            }
                .dependency(product: "ApodiniMigratorClientSupport", of: "ApodiniMigrator")
                .resource(type: .process, path: "Resources")
        }

        Tests {
            TestTarget("\(.packageName)Tests") {
                ModelTestsFile(
                    name: "\(.packageName)Tests.swift",
                    models: document.models.fileRenderableTypes(),
                    objectJSONs: migrationGuide.objectJSONs,
                    encoderConfiguration: encoderConfiguration
                )

                ResourceFile(copy: "XCTestManifests.swift", filePrefix: { FileHeaderComment() })
            }
                .dependency(target: .packageName)

            StubLinuxMainFile(prefix: { FileHeaderComment() })
        }

        SwiftPackageFile(swiftTools: "5.5")
            .platform(".macOS(.v11)", ".iOS(.v13)")
            .dependency(url: "https://github.com/Apodini/ApodiniMigrator.git", ".upToNextMinor(from: \"0.3.0\")")
            .product(library: .packageName, targets: .packageName)

        ReadMeFile("Readme.md")
    }
}
