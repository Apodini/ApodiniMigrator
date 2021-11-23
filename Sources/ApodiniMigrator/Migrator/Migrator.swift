//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Logging
import MigratorAPI

public struct RESTMigrator: MigratorAPI.Migrator {
    public var bundle = Bundle.module

    @SharedNodeStorage
    var apiFileMigratedEndpoints: [MigratedEndpoint]

    private let document: Document
    private let migrationGuide: MigrationGuide
    private let changeFilter: ChangeFilter

    /// Networking migrator
    private let networkingMigrator: NetworkingMigrator

    public var library: RootDirectory {
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
                    ResourceFile(copy: "ApodiniError.swift")
                    ResourceFile(copy: "HTTPAuthorization.swift")
                    ResourceFile(copy: "HTTPHeaders.swift")
                    ResourceFile(copy: "HTTPMethod.swift")
                    ResourceFile(copy: "Parameters.swift")
                }

                Directory("Models") {
                    // TODO generate
                    Empty()
                }

                Directory("Networking") {
                    ResourceFile(copy: "Handler.swift")
                    ResourceFile(copy: "NetworkingService.swift")
                        .replacing(Placeholder("serverpath"), with: networkingMigrator.serverPath())
                        .replacing(Placeholder("encoder___configuration"), with: networkingMigrator.encoderConfiguration().networkingDescription)
                        .replacing(Placeholder("decoder___configuration"), with: networkingMigrator.decoderConfiguration().networkingDescription)
                }

                Directory("Resources") {
                    // TODO script generation
                    Empty()
                }

                Directory("Utils") {
                    ResourceFile(copy: "Utils.swift")
                }

                APIFile($apiFileMigratedEndpoints)
            }
                .dependency(product: "ApodiniMigratorClientSupport", of: "ApodiniMigrator")
                // TODO resources!
        }

        Tests {
            TestTarget(GlobalPlaceholder.$packageName, "Tests") {
                Empty()
                // TODO generate tests
            }
                .dependency(target: "TestClient") // TODO replacer!
            // TODO removing linux main
        }

        SwiftPackageFile(swiftTools: "5.5")
            .dependency(url: "https://github.com/Apodini/ApodiniMigrator.git", ".upToNextMinor(from: \"0.1.0\")")
            .product(library: GlobalPlaceholder.$packageName, targets: [[GlobalPlaceholder.$packageName]]) // TODO double array
        ReadMeFile("Readme.md")
    }

    public init(documentPath: String, migrationGuide: MigrationGuide = .empty) throws {
        try self.document = Document.decode(from: documentPath.asPath)

        if let id = migrationGuide.id, document.id != id {
            throw Migrator.MigratorError.incompatible(
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
    public let directories: ProjectDirectories
    
    /// Logger of the migrator
    private let logger: Logger
    /// Endpoints migrator
    private let endpointsMigrator: EndpointsMigrator
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
        
        self.directories = ProjectDirectories(packageName: packageName, packagePath: packagePath)
        self.scripts = migrationGuide.scripts
        self.jsonValues = migrationGuide.jsonValues
        self.objectJSONs = migrationGuide.objectJSONs
        let changeFilter: ChangeFilter = .init(migrationGuide)
        endpointsMigrator = .init(
            endpointsPath: directories.endpoints,
            apiFilePath: directories.target,
            allEndpoints: document.endpoints + changeFilter.addedEndpoints(),
            endpointChanges: changeFilter.endpointChanges
        )
        let oldModels = document.allModels()
        let addedModels = changeFilter.addedModels()
        self.allModels = oldModels + addedModels
        modelsMigrator = .init(
            path: directories.models,
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
        try directories.build()
        
        try writeRootFiles()
        
        try writeHTTP()
        
        try writeUtils()
        
        try writeResources()
        
        log(.endpoints)
        try endpointsMigrator.migrate()
        
        log(.models)
        try modelsMigrator.migrate()
        
        try writeNetworking()
        
        try writeTests()
    }
    
    /// Writes files at the root of the project
    private func writeRootFiles() throws {
        let readMe = readTemplate(.readme)
        
        try (directories.root + .readme).write(readMe)
        
        let package = readTemplate(.package)
            .with(packageName: packageName)
            .indentationFormatted()
        
        try (directories.root + .package).write(package)
    }
    
    /// Writes files of `HTTP` directory
    private func writeHTTP() throws {
        log(.http)
        let https = Template.httpTemplates
        
        try https.forEach { template in
            let path = directories.http + template
            try path.write(templateContentWithFileComment(template))
        }
    }
    
    /// Writes files of `Utils` directory
    private func writeUtils() throws {
        log(.utils)
        let utils = templateContentWithFileComment(.utils)
        
        try (directories.utils + Template.utils).write(utils)
    }
    
    /// Writes files at `Resources`
    private func writeResources() throws {
        log(.resources)
        try (directories.resources + Resources.jsScripts.rawValue).write(scripts.json)
        try (directories.resources + Resources.jsonValues.rawValue).write(jsonValues.json)
    }
    
    /// Writes files at `Networking` directory
    private func writeNetworking() throws {
        log(.networking)
        let serverPath = networkingMigrator.serverPath()
        let encoderConfiguration = self.encoderConfiguration.networkingDescription
        let decoderConfiguration = networkingMigrator.decoderConfiguration().networkingDescription
        let handler = templateContentWithFileComment(.handler)
        let networking = templateContentWithFileComment(.networkingService, indented: false)
            .with(serverPath, insteadOf: Template.serverPath)
            .with(encoderConfiguration, insteadOf: Template.encoderConfiguration)
            .with(decoderConfiguration, insteadOf: Template.decoderConfiguration)
            .indentationFormatted()
        let networkingDirectory = directories.networking
        
        try (networkingDirectory + .handler).write(handler)
        try (networkingDirectory + .networkingService).write(networking)
    }
    
    /// Writes files at test target
    private func writeTests() throws {
        log(.tests)
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
    }
    
    /// A util function to log persisting of content at a directory
    private func log(_ directory: DirectoryName) {
        logger.info("Persisting content at \(directories.path(of: directory).string.without(packagePath.string + "/"))")
    }
    
    /// A util function that returns the string content of a template
    private func readTemplate(_ template: Template) -> String {
        template.content()
    }
    
    /// Returns the string content of template file by also added the file header comment
    private func templateContentWithFileComment(_ template: Template, indented: Bool = true, alternativeFileName: String? = nil) -> String {
        let fileHeader = FileHeaderComment(fileName: alternativeFileName ?? template.projectFileName).render() + .doubleLineBreak
        let fileContent = fileHeader + readTemplate(template)
        return indented ? fileContent.indentationFormatted() : fileContent
    }
}


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

extension String {
    func with(packageName: String) -> String {
        with(packageName, insteadOf: Template.packageName)
    }
}
