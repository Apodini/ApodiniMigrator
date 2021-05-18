//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import PathKit
import ApodiniMigrator
import ApodiniMigratorShared

public struct ApodiniMigratorGenerator {
    public let packageName: String
    public let packagePath: Path
    public var document: Document
    public let directories: ProjectDirectories
    public let endpoints: [Endpoint]
    public let metaData: MetaData
    
    public init(packageName: String, packagePath: String, documentPath: String) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = Path(packagePath)
        document = try JSONDecoder().decode(Document.self, from: try Path(documentPath).read())
        document.dereference()
        self.directories = ProjectDirectories(packageName: packageName, packagePath: self.packagePath)
        endpoints = document.endpoints
        metaData = document.metaData
    }
    
    public func build() throws {
        try directories.build()
        try writeRootFiles()
        try writeHTTP()
        try writeNetworking()
        try writeUtils()
        try writeModels()
        try writeEndpoints()
        try writeTests()
    }
    
    private func readTemplate(_ template: Template) -> String {
        template.content()
    }
    
    private func writeRootFiles() throws {
        let readMe = readTemplate(.readme)
        
        try (directories.root + Template.readme.projectFileName).write(readMe)
        
        let package = readTemplate(.package)
            .with(packageName: packageName)
            .formatted(with: IndentationFormatter.self)
        
        try (directories.root + Template.package.projectFileName).write(package)
    }
    
    private func writeHTTP() throws {
        let https = Template.httpTemplates
        
        try https.forEach { template in
            let path = directories.http + template.projectFileName
            try path.write(templateContentWithFileComment(template))
        }
    }
    
    private func writeModels() throws { // TODO distinguish decodable encodable
        let models = endpoints.reduce(into: Set<TypeInformation>()) { result, current in
            result.insert(current.restResponse)
            current.parameters.forEach { parameter in
                result.insert(parameter.typeInformation)
            }
        }
        
        let recursiveFileGenerator = try RecursiveFileGenerator(Array(models))
        try recursiveFileGenerator.persist(at: directories.models)
    }
    
    private func writeEndpoints() throws {
        let endpointGroups = endpoints.reduce(into: [TypeInformation: Set<Endpoint>]()) { result, current in
            let restResponse = current.restResponse
            if result[restResponse] == nil {
                result[restResponse] = []
            }
            result[restResponse]?.insert(current)
        }
        let endpointsDirectory = directories.endpoints
        for group in endpointGroups {
            let filePath = group.key.typeName.name + "+Endpoint.swift"
            let endpointFileTemplate = try EndpointFileTemplate(with: group.key, endpoints: Array(group.value))
            try (endpointsDirectory + filePath).write(endpointFileTemplate.render().formatted(with: IndentationFormatter.self))
        }
    }
    
    private func writeNetworking() throws {
        let metaData = document.metaData
        let serverPath = metaData.serverPath
        let encoderConfiguration = metaData.encoderConfiguration.networkingDescription
        let decoderConfiguration = metaData.decoderConfiguration.networkingDescription
        let handler = templateContentWithFileComment(.handler)
        let networking = templateContentWithFileComment(.networkingService)
            .replacingOccurrences(of: Template.serverPath, with: serverPath)
            .replacingOccurrences(of: Template.encoderConfiguration, with: encoderConfiguration)
            .replacingOccurrences(of: Template.decoderConfiguration, with: decoderConfiguration)
            .formatted(with: IndentationFormatter.self)
        
        let networkingDirectory = directories.networking
        
        try (networkingDirectory + Template.handler.projectFileName).write(handler)
        try (networkingDirectory + Template.networkingService.projectFileName).write(networking)
    }
    
    private func writeUtils() throws {
        let utils = templateContentWithFileComment(.utils)
        
        try (directories.utils + Template.utils.projectFileName).write(utils)
    }
    
    private func writeTests() throws {
        let tests = directories.tests
        let testsTarget = directories.testsTarget
        let testFileName = packageName + "Tests.swift"
        let testFile = templateContentWithFileComment(.testFile, alternativeFileName: testFileName)
            .with(packageName: packageName)
        try (testsTarget + testFileName).write(testFile)
        
        let manifests = templateContentWithFileComment(.xCTestManifests).with(packageName: packageName)
        try (testsTarget + Template.xCTestManifests.projectFileName).write(manifests)
        let linuxMain = readTemplate(.linuxMain)
        
        try (tests + Template.linuxMain.projectFileName).write(linuxMain)
    }
    
    private func templateContentWithFileComment(_ template: Template, alternativeFileName: String? = nil) -> String {
        let fileHeader = FileHeaderComment(fileName: alternativeFileName ?? template.projectFileName).render() + .doubleLineBreak
        
        return (fileHeader + readTemplate(template)).formatted(with: IndentationFormatter.self)
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
