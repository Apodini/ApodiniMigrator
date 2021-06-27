//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

import Logging
@_exported import ApodiniMigratorCompare

/// A generator for a swift package
public struct Migrator {
    public static let logger: Logger = {
        .init(label: "org.apodini.migrator")
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
    
    let endpointsMigrator: EndpointsMigrator
    let modelsMigrator: ModelsMigrator
    let networkingMigrator: NetworkingMigrator
    let scripts: [Int: JSScript]
    let jsonValues: [Int: JSONValue]
    let allModels: [TypeInformation]
    let objectJSONs: [String: JSONValue]
    let encoderConfiguration: EncoderConfiguration
    private var useTemplateTestFile = false
    
    
    public init(packageName: String, packagePath: String, documentPath: String, migrationGuide: MigrationGuide) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = packagePath.asPath
        document = try Document.decode(from: documentPath.asPath)
        self.directories = ProjectDirectories(packageName: packageName, packagePath: packagePath)
        self.scripts = migrationGuide.scripts
        self.jsonValues = migrationGuide.jsonValues
        self.objectJSONs = migrationGuide.objectJSONs
        let changeFilter: ChangeFilter = .init(migrationGuide)
        endpointsMigrator = .init(
            endpointsPath: directories.endpoints,
            webServicePath: directories.target,
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
            networkingPath: directories.networking,
            oldMetaData: document.metaData,
            networkingChanges: changeFilter.networkingChanges
        )
        self.encoderConfiguration = networkingMigrator.encoderConfiguration()
        
        logger = Self.logger
    }
    
    public func migrate() throws {
        try directories.build()
        
        try writeRootFiles()
        
        try writeHTTP()
        
        try writeUtils()
        
        try writeResources()
        
        try endpointsMigrator.migrate()
        
        try modelsMigrator.migrate()
        
        try writeNetworking()
        
        try writeTests()
    }
    
    private func writeResources() throws {
        try (directories.resources + Resources.jsScripts.rawValue).write(scripts.json)
        try (directories.resources + Resources.jsonValues.rawValue).write(jsonValues.json)
    }
    
    private func writeNetworking() throws {
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
    
    private func readTemplate(_ template: Template) -> String {
        template.content()
    }
    
    private func writeTests() throws {
        let tests = directories.tests
        let testsTarget = directories.testsTarget
        let testFileName = packageName + "Tests" + .swift
        let testFile = useTemplateTestFile
            ? templateContentWithFileComment(.testFile, alternativeFileName: testFileName).with(packageName: packageName)
            : TestFileTemplate(
                allModels,
                objectJSONs: objectJSONs,
                encoderConfiguration: encoderConfiguration,
                fileName: testFileName,
                packageName: packageName
            )
            .render()
            .indentationFormatted()
            
        
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
    
    
    private func templateContentWithFileComment(_ template: Template, indented: Bool = true, alternativeFileName: String? = nil) -> String {
        let fileHeader = FileHeaderComment(fileName: alternativeFileName ?? template.projectFileName).render() + .doubleLineBreak
        let fileContent = fileHeader + readTemplate(template)
        return indented ? fileContent.indentationFormatted() : fileContent
    }
}
    
fileprivate extension String {
    func with(packageName: String) -> String {
        with(packageName, insteadOf: Template.packageName)
    }
}
