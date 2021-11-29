//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

// TODO remove the Migrator subfolder! and move the whole thing into a RESTMigrator target!

import Foundation
import Logging
import MigratorAPI

public struct RESTMigrator: MigratorAPI.Migrator {
    enum MigratorError: Error {
        case incompatible(message: String)
    }

    public var bundle = Bundle.module

    public static let logger: Logger = {
        .init(label: "org.apodini.migrator.rest")
    }()

    @SharedNodeStorage
    var apiFileMigratedEndpoints: [MigratedEndpoint]

    private let document: Document
    private let migrationGuide: MigrationGuide
    private let changeFilter: ChangeFilter

    /// Networking migrator
    private let networkingMigrator: NetworkingMigrator

    // TODO incorporate logger and according logging of progress!

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
                TestFileTemplate(
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
            .dependency(url: "https://github.com/Apodini/ApodiniMigrator.git", ".upToNextMinor(from: \"0.1.0\")")
            .product(library: GlobalPlaceholder.$packageName, targets: [[GlobalPlaceholder.$packageName]])
            // TODO double array ABOVE!
        ReadMeFile("Readme.md")
    }

    public init(documentPath: String, migrationGuide: MigrationGuide = .empty) throws {
        try self.document = Document.decode(from: Path(documentPath))

        if let id = migrationGuide.id, document.id != id {
            throw MigratorError.incompatible(
                message:
                """
                Migration guide is not compatible with the provided document. Apparently another old document version, \
                has been used to generate the migration guide!
                """
            )
        }

        self.migrationGuide = migrationGuide
        self.changeFilter = ChangeFilter(migrationGuide)

        networkingMigrator = NetworkingMigrator(
            previousServerInformation: document.metaData,
            networkingChanges: changeFilter.networkingChanges
        )
    }
}

// TODO finally remove old Migrator!
/*

/// A generator for a swift package
public struct Migrator {
    enum MigratorError: Error {
        case incompatible(message: String)
    }
    
    /// Migrator logger labeled `org.apodini.migrator`
    public static let logger: Logger = {
        .init(label: "org.apodini.migrator")
    }()
    
    /// Name of the package to be migrated
    private let packageName: String
    /// Path of the package
    private let packagePath: Path
    /// Document of the current version of the package
    private var document: Document
    /// Directories of the package
    //public let directories: ProjectDirectories = .init(packageName: "", packagePath: "") // TODO remove!
    
    /// Logger of the migrator
    private let logger: Logger
    /// Endpoints migrator
    // TODO removed private let endpointsMigrator: EndpointsMigrator
    /// Models migrator
    private let modelsMigrator: ModelsMigrator
    /// Networking migrator
    private let networkingMigrator: NetworkingMigrator
    /// All models of the client library (including old, deleted and added ones)
    private let allModels: [TypeInformation]
    /// Dictionary of js script convert methods from the migration guide
    private let scripts: [Int: JSScript]
    /// Dictionary of json values from the migration guide
    private let jsonValues: [Int: JSONValue]
    /// Dictionary of updated json representations from the migration guide
    private let objectJSONs: [String: JSONValue]
    /// Encoder configuration of the new version as calculated by the `networkingMigrator`
    private let encoderConfiguration: EncoderConfiguration
    
    /// Initializes a new Migrator instance
    /// - Parameters:
    ///    - packageName: name of the package
    ///    - packagePath: path of the package
    ///    - documentPath: path where the document is located
    ///    - migrationGuide: migration guide
    public init(packageName: String, packagePath: String, documentPath: String, migrationGuide: MigrationGuide = .empty) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = packagePath.asPath
        document = try Document.decode(from: documentPath.asPath)
        if let id = migrationGuide.id, document.id != id {
            throw MigratorError.incompatible(
                message:
                    """
                    Migration guide is not compatible with the provided document. Apparently another old document version,
                    has been used to generate the migration guide
                    """
            )
        }
        
        // self.directories = ProjectDirectories(packageName: packageName, packagePath: packagePath)
        self.scripts = migrationGuide.scripts
        self.jsonValues = migrationGuide.jsonValues
        self.objectJSONs = migrationGuide.objectJSONs
        let changeFilter: ChangeFilter = .init(migrationGuide)
        /*endpointsMigrator = .init(
            endpointsPath: directories.endpoints,
            apiFilePath: directories.target,
            allEndpoints: document.endpoints + changeFilter.addedEndpoints(),
            endpointChanges: changeFilter.endpointChanges
        )*/
        let oldModels = document.allModels()
        let addedModels = changeFilter.addedModels()
        self.allModels = oldModels + addedModels
        modelsMigrator = .init(
            // path: directories.models,
            oldModels: oldModels,
            addedModels: addedModels,
            modelChanges: changeFilter.modelChanges
        )
        
        networkingMigrator = .init(
            previousServerInformation: document.metaData,
            networkingChanges: changeFilter.networkingChanges
        )
        self.encoderConfiguration = networkingMigrator.encoderConfiguration()
        
        logger = Self.logger
    }

    /// Triggers the rendering of migrated content of the library and persists changes
    public func run() throws {
        logger.info("Preparing project directories...")
        // try directories.build()

        // TODO for each line there was a logging statement!
        // try writeRootFiles()
        
        // try writeHTTP()
        
        // try writeUtils()
        
        // try writeResources()
        
        //log(.endpoints)
        // TODO removed try endpointsMigrator.migrate()
        
        //log(.models)
        // TODO removed! try modelsMigrator.migrate()
        
        try writeNetworking()
        
        try writeTests()
    }
    
    /// Writes files at `Networking` directory
    private func writeNetworking() throws {
        // log(.networking)
        let serverPath = networkingMigrator.serverPath()
        let encoderConfiguration = self.encoderConfiguration.networkingDescription
        let decoderConfiguration = networkingMigrator.decoderConfiguration().networkingDescription
        let handler = templateContentWithFileComment(.handler)
        let networking = templateContentWithFileComment(.networkingService, indented: false)
            .with(serverPath, insteadOf: Template.serverPath)
            .with(encoderConfiguration, insteadOf: Template.encoderConfiguration)
            .with(decoderConfiguration, insteadOf: Template.decoderConfiguration)
            // TODO .indentationFormatted()
        //let networkingDirectory = directories.networking
        
        //try (networkingDirectory + .handler).write(handler)
        //try (networkingDirectory + .networkingService).write(networking)
    }
    
    /// Writes files at test target
    private func writeTests() throws {
        // log(.tests)
        /*
        let tests = directories.tests
        let testsTarget = directories.testsTarget
        let testFileName = packageName + "Tests" + .swift
        let testFile = TestFileTemplate(
            allModels,
            objectJSONs: objectJSONs,
            encoderConfiguration: encoderConfiguration,
            fileName: testFileName,
            packageName: packageName
        ).render().indentationFormatted()
        
        try (testsTarget + testFileName).write(testFile)
        
        let manifests = templateContentWithFileComment(.xCTestManifests).with(packageName: packageName)
        try (testsTarget + .xCTestManifests).write(manifests)
        let linuxMain = readTemplate(.linuxMain)
        
        try (tests + .linuxMain).write(linuxMain.indentationFormatted())
        */
    }
    
    /// A util function to log persisting of content at a directory
    // private func log(_ directory: DirectoryName) {
        // TODO logger.info("Persisting content at \(directories.path(of: directory).string.without(packagePath.string + "/"))")
    //}
    
    /// Returns the string content of template file by also added the file header comment
    private func templateContentWithFileComment(_ template: Template, indented: Bool = true, alternativeFileName: String? = nil) -> String {
        /*let fileHeader = FileHeaderComment(fileName: alternativeFileName ?? template.projectFileName).render() + .doubleLineBreak
        let fileContent = fileHeader + readTemplate(template)
        return indented ? fileContent.indentationFormatted() : fileContent*/
         return ""
    }
}
*/

// TODO move somewhere?
extension DecoderConfiguration {
    var networkingDescription: String {
        """
        dateDecodingStrategy: .\(dateDecodingStrategy.rawValue),
        dataDecodingStrategy: .\(dataDecodingStrategy.rawValue)
        """
    }
}

extension EncoderConfiguration {
    var networkingDescription: String {
        """
        dateEncodingStrategy: .\(dateEncodingStrategy.rawValue),
        dataEncodingStrategy: .\(dataEncodingStrategy.rawValue)
        """
    }
}
