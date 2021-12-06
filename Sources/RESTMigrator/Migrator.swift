//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Logging
import ApodiniMigrator

public struct RESTMigrator: ApodiniMigrator.Migrator {
    enum MigratorError: Error {
        case incompatible(message: String)
    }

    public var bundle = Bundle.module

    public static let logger: Logger = {
        .init(label: "org.apodini.migrator.rest")
    }()
    // TODO incorporate logger and according logging of progress!
    // TODO logger.info("Persisting content at \(directories.path(of: directory).string.without(packagePath.string + "/"))")

    private let document: Document
    private let migrationGuide: MigrationGuide
    private let changeFilter: ChangeFilter

    /// Networking migrator
    private let networkingMigrator: NetworkingMigrator

    @SharedNodeStorage
    var apiFileMigratedEndpoints: [MigratedEndpoint]

    public init(documentPath: String, migrationGuidePath: String? = nil) throws {
        try self.document = Document.decode(from: Path(documentPath))

        if let path = migrationGuidePath {
            try self.migrationGuide = MigrationGuide.decode(from: Path(path))
        } else {
            self.migrationGuide = .empty
        }

        if let id = migrationGuide.id, document.id != id {
            throw MigratorError.incompatible(
                message:
                """
                Migration guide is not compatible with the provided document. Apparently another old document version, \
                has been used to generate the migration guide!
                """
            )
        }
        self.changeFilter = ChangeFilter(migrationGuide)

        networkingMigrator = NetworkingMigrator(
            previousServerInformation: document.metaData,
            networkingChanges: changeFilter.networkingChanges
        )
    }

    public var library: RootDirectory {
        let allModels = document.allModels()
        let encoderConfiguration = networkingMigrator.encoderConfiguration()
        let decoderConfiguration = networkingMigrator.decoderConfiguration()

        Sources {
            Target(GlobalPlaceholder.$packageName) {
                Directory("Endpoints") {
                    EndpointsMigrator(
                        migratedEndpointsReference: $apiFileMigratedEndpoints,
                        allEndpoints: document.endpoints + changeFilter.addedEndpoints(),
                        endpointChanges: changeFilter.endpointChanges
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
                        oldModels: allModels,
                        addedModels: changeFilter.addedModels(),
                        modelChanges: changeFilter.modelChanges
                    )
                }

                Directory("Networking") {
                    ResourceFile(copy: "Handler.swift", filePrefix: { FileHeaderComment() })
                    ResourceFile(copy: "NetworkingService.swift", filePrefix: { FileHeaderComment() })
                        .replacing(Placeholder("serverpath"), with: networkingMigrator.serverPath())
                        .replacing(Placeholder("encoder___configuration"), with: encoderConfiguration.networkingDescription)
                        .replacing(Placeholder("decoder___configuration"), with: decoderConfiguration.networkingDescription)
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
            TestTarget(GlobalPlaceholder.$packageName, "Tests") {
                ModelTestsFile(
                    name: GlobalPlaceholder.$packageName, "Tests.swift",
                    models: allModels,
                    objectJSONs: migrationGuide.objectJSONs,
                    encoderConfiguration: encoderConfiguration
                )

                ResourceFile(copy: "XCTestManifests.swift", filePrefix: { FileHeaderComment() })
            }
                .dependency(target: GlobalPlaceholder.$packageName)

            // TODO ResourceFile(Copy: "LinuxMain.swift", filePrefix: { FileHeaderComment() })
        }

        SwiftPackageFile(swiftTools: "5.5")
            .platform(".macOS(.v12)", ".iOS(.v14)")
            .dependency(url: "https://github.com/Apodini/ApodiniMigrator.git", ".upToNextMinor(from: \"0.1.0\")")
            .product(library: GlobalPlaceholder.$packageName, targets: [[GlobalPlaceholder.$packageName]])

        ReadMeFile("Readme.md")
    }
}
