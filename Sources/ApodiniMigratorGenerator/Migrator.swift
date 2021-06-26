//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

import Foundation
import Logging
@_exported import ApodiniMigratorCompare

/// A generator for a swift package
public struct Migrator {
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

    private let logger: Logger
    
    public let changeFilter: ChangeFilter
    
    let endpointsMigrator: EndpointsMigrator
    let modelsMigrator: ModelsMigrator
    let networkingMigrator: NetworkingMigrator
    let allModels: [TypeInformation]
    let objectJSONs: [String: JSONValue]
    let encoderConfiguration: EncoderConfiguration
    private var useTemplateTestFile = false
    
    
    public init(packageName: String, packagePath: String, documentPath: String, migrationGuide: MigrationGuide) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = packagePath.asPath
        document = try Document.decode(from: documentPath.asPath)
        self.directories = ProjectDirectories(packageName: packageName, packagePath: packagePath)
        changeFilter = migrationGuide.changeFilter
        endpointsMigrator = .init(
            endpointsPath: directories.endpoints,
            webServicePath: directories.networking,
            oldEndpoints: document.endpoints,
            addedEndpoints: changeFilter.addedEndpoints(),
            deletedEndpointIDs: changeFilter.deletedEndpointIDs(),
            endpointChanges: changeFilter.endpointChanges
        )
        let oldModels = document.allModels()
        let addedModels = changeFilter.addedModels()
        modelsMigrator = .init(
            path: directories.models,
            oldModels: oldModels,
            addedModels: addedModels,
            modelChanges: changeFilter.modelChanges
        )
        self.allModels = oldModels + addedModels
        networkingMigrator = .init(
            networkingPath: directories.networking,
            oldMetaData: document.metaData,
            networkingChanges: changeFilter.networkingChanges
        )
        self.encoderConfiguration = networkingMigrator.encoderConfiguration()
        self.objectJSONs = migrationGuide.objectJSONs
        logger = Self.logger
    }
    
    public func migrate() throws {
        try directories.build()
        
        try writeRootFiles()
        
        try writeHTTP()
        
        try writeUtils()
        
        try writeResources()
        
        try endpointsMigrator.build()
        
        try modelsMigrator.build()
        
        try writeNetworking()
        
        try writeTests()
    }
    
    private func writeResources() throws {
        let migrationGuide = changeFilter.migrationGuide
        let jsScripts = migrationGuide.scripts
        let jsonValues = migrationGuide.jsonValues
        
        try (directories.resources + Resources.jsScripts.rawValue).write(jsScripts.json)
        try (directories.resources + Resources.jsonValues.rawValue).write(jsonValues.json)
    }
    
    private func writeNetworking() throws {
        let serverPath = networkingMigrator.serverPath()
        let encoderConfiguration = self.encoderConfiguration.networkingDescription
        let decoderConfiguration = networkingMigrator.decoderConfiguration().networkingDescription
        let handler = templateContentWithFileComment(.handler)
        let networking = templateContentWithFileComment(.networkingService)
            .with(serverPath, insteadOf: Template.serverPath)
            .with(encoderConfiguration, insteadOf: Template.encoderConfiguration)
            .with(decoderConfiguration, insteadOf: Template.decoderConfiguration)
//        let webServiceFile = WebServiceFileTemplate(endpoints).render().indentationFormatted()
        let networkingDirectory = directories.networking
        
        try (networkingDirectory + .handler).write(handler)
        try (networkingDirectory + .networkingService).write(networking)
//        try (networkingDirectory + (WebServiceFileTemplate.fileName + .swift)).write(webServiceFile)
    }
    
    private func readTemplate(_ template: Template) -> String {
        template.content()
    }
    
    private func writeTests() throws {
        let tests = directories.tests
        let testsTarget = directories.testsTarget
        let testFileName = packageName + "Tests" + .swift
        let testFile = useTemplateTestFile
            ? templateContentWithFileComment(.testFile, alternativeFileName: testFileName).with(packageName: packageName)
            : TestFileTemplate(allModels, objectJSONs: objectJSONs, encoderConfiguration: encoderConfiguration, fileName: testFileName, packageName: packageName).render().indentationFormatted()
            
        
        try (testsTarget + testFileName).write(testFile)
        
        let manifests = templateContentWithFileComment(.xCTestManifests).with(packageName: packageName)
        try (testsTarget + .xCTestManifests).write(manifests)
        let linuxMain = readTemplate(.linuxMain)
        
        try (tests + .linuxMain).write(linuxMain.indentationFormatted())
    }
    
    private func writeUtils() throws {
        let utils = templateContentWithFileComment(.utils)
        
        try (directories.utils + Template.utils).write(utils)
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
    
    
    private func templateContentWithFileComment(_ template: Template, alternativeFileName: String? = nil) -> String {
        let fileHeader = FileHeaderComment(fileName: alternativeFileName ?? template.projectFileName).render() + .doubleLineBreak
        
        return (fileHeader + readTemplate(template)).indentationFormatted()
    }
}
    
fileprivate extension String {
    func with(packageName: String) -> String {
        with(packageName, insteadOf: Template.packageName)
    }
}
