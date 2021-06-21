//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import Logging
@_exported import ApodiniMigratorCompare

/// A generator for a swift package
public struct ApodiniMigratorGenerator {
    public static let logger: Logger = {
        .init(label: "de.apodini.migrator.generator")
    }()
    
    /// Name of the package to be generated
    public let packageName: String
    /// Path of the package
    public let packagePath: Path
    /// Document used to generate the package
    public var document: Document
    /// Directories of the package
    public let directories: ProjectDirectories
    /// Endpoints
    public let endpoints: [Endpoint]
    public let addedEndpoints: [Endpoint]
    /// Metadata retrieved from the document
    public let metaData: MetaData
    /// all models of the document
    private let allModels: [TypeInformation]
    /// logger of package generator
    private let logger: Logger
    
    public let changeFilter: ChangeFilter
    /// TODO remove
    private var useTemplateTestFile = false
    
    /// Initializes a new instance with a `packageName`, string `packagePath` and the string `documentPath`
    public init(packageName: String, packagePath: String, documentPath: String, migrationGuide: MigrationGuide) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = packagePath.asPath
        document = try Document.decode(from: documentPath.asPath)
        self.directories = ProjectDirectories(packageName: packageName, packagePath: packagePath)
        changeFilter = migrationGuide.changeFilter
        endpoints = document.endpoints
        addedEndpoints = changeFilter.addedEndpoints()
        metaData = document.metaData
        allModels = document.allModels()
        self.logger = Self.logger
    }
    
    /// Builds and persists the content of the package at the specified path
    public func build() throws {
        logger.info("Preparing project directories...")
        try directories.build()
        try writeRootFiles()
        logger.info("Persisting content at \(directories.http.string)")
        try writeHTTP()
        logger.info("Persisting content at \(directories.networking.string)")
        try writeNetworking()
        logger.info("Persisting content at \(directories.utils.string)")
        try writeUtils()
        logger.info("Persisting content at \(directories.models.string)")
        try writeModels()
        logger.info("Persisting content at \(directories.endpoints.string)")
        try writeEndpoints()
        logger.info("Persisting content at \(directories.tests.string)")
        try writeTests()
    }
    
    private func readTemplate(_ template: Template) -> String {
        template.content()
    }
    
    private func writeRootFiles() throws {
        let readMe = readTemplate(.readme)
        
        try (directories.root + .readme).write(readMe)
        
        let package = readTemplate(.package)
            .with(packageName: packageName)
            .indentationFormatted()
        
        try (directories.root + .package).write(package)
    }
    
    private func writeHTTP() throws {
        let https = Template.httpTemplates
        
        try https.forEach { template in
            let path = directories.http + template
            try path.write(templateContentWithFileComment(template))
        }
    }
    
    private func writeModels() throws {
        let recursiveFileGenerator = try MultipleFileGenerator(allModels)
        try recursiveFileGenerator.persist(at: directories.models)
    }
    
    private func writeEndpoints() throws {
        let endpointGroups = endpoints.reduce(into: [TypeInformation: Set<Endpoint>]()) { result, current in
            let nestedResponseType = current.response.nestedType
            result[nestedResponseType, default: []].insert(current)
        }
        let endpointsDirectory = directories.endpoints
        for group in endpointGroups {
            let filePath = group.key.typeName.name + EndpointFileTemplate.fileSuffix
            let endpointFileTemplate = EndpointFileTemplate(with: group.key, endpoints: Array(group.value))
            try (endpointsDirectory + filePath).write(endpointFileTemplate.render().indentationFormatted())
        }
    }
    
    private func writeNetworking() throws {
        let metaData = document.metaData
        let serverPath = metaData.versionedServerPath
        let encoderConfiguration = metaData.encoderConfiguration.networkingDescription
        let decoderConfiguration = metaData.decoderConfiguration.networkingDescription
        let handler = templateContentWithFileComment(.handler)
        let networking = templateContentWithFileComment(.networkingService)
            .replacingOccurrences(of: Template.serverPath, with: serverPath)
            .replacingOccurrences(of: Template.encoderConfiguration, with: encoderConfiguration)
            .replacingOccurrences(of: Template.decoderConfiguration, with: decoderConfiguration)
            .indentationFormatted()
        let webServiceFile = WebServiceFileTemplate(endpoints).render().indentationFormatted()
        let networkingDirectory = directories.networking
        
        try (networkingDirectory + .handler).write(handler)
        try (networkingDirectory + .networkingService).write(networking)
        try (networkingDirectory + (WebServiceFileTemplate.fileName + .swift)).write(webServiceFile)
    }
    
    private func writeUtils() throws {
        let utils = templateContentWithFileComment(.utils)
        
        try (directories.utils + Template.utils).write(utils)
    }
    
    private func writeTests() throws {
        let tests = directories.tests
        let testsTarget = directories.testsTarget
        let testFileName = packageName + "Tests" + .swift
        let testFile = useTemplateTestFile
            ? templateContentWithFileComment(.testFile, alternativeFileName: testFileName).with(packageName: packageName)
            : TestFileTemplate(allModels, fileName: testFileName, packageName: packageName).render().indentationFormatted()
        
        try (testsTarget + testFileName).write(testFile)
        
        let manifests = templateContentWithFileComment(.xCTestManifests).with(packageName: packageName)
        try (testsTarget + .xCTestManifests).write(manifests)
        let linuxMain = readTemplate(.linuxMain)
        
        try (tests + .linuxMain).write(linuxMain.indentationFormatted())
    }
    
    private func templateContentWithFileComment(_ template: Template, alternativeFileName: String? = nil) -> String {
        let fileHeader = FileHeaderComment(fileName: alternativeFileName ?? template.projectFileName).render() + .doubleLineBreak
        
        return (fileHeader + readTemplate(template)).indentationFormatted()
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

fileprivate extension String {
    func with(packageName: String) -> String {
        replacingOccurrences(of: Template.packageName, with: packageName)
    }
}
