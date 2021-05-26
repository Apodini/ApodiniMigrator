//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation

public struct ApodiniMigratorGenerator {
    public let packageName: String
    public let packagePath: Path
    public var document: Document
    public let directories: ProjectDirectories
    public let endpoints: [Endpoint]
    public let metaData: MetaData
    private let allModels: [TypeInformation]
    
    public init(packageName: String, packagePath: String, documentPath: String) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = Path(packagePath)
        document = try JSONDecoder().decode(Document.self, from: try Path(documentPath).read())
        self.directories = ProjectDirectories(packageName: packageName, packagePath: self.packagePath)
        endpoints = document.endpoints
        metaData = document.metaData
        allModels = endpoints.reduce(into: Set<TypeInformation>()) { result, current in
            result.insert(current.response)
            current.parameters.forEach { parameter in
                result.insert(parameter.typeInformation)
            }
        }.asArray.fileRenderableTypes().sorted(by: \.typeName)
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
        
        try (directories.root + .readme).write(readMe)
        
        let package = readTemplate(.package)
            .with(packageName: packageName)
            .formatted(with: IndentationFormatter.self)
        
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
        let recursiveFileGenerator = try RecursiveFileGenerator(allModels)
        try recursiveFileGenerator.persist(at: directories.models)
    }
    
    private func writeEndpoints() throws {
        let endpointGroups = endpoints.reduce(into: [TypeInformation: Set<Endpoint>]()) { result, current in
            let nestedResponseType = current.response.nestedType
            if result[nestedResponseType] == nil {
                result[nestedResponseType] = []
            }
            result[nestedResponseType]?.insert(current)
        }
        let endpointsDirectory = directories.endpoints
        for group in endpointGroups {
            let filePath = group.key.typeName.name + EndpointFileTemplate.fileSuffix
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
        let webServiceFile = WebServiceFileTemplate(endpoints).render().formatted(with: IndentationFormatter.self)
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
        let testFile = TestFileTemplate(allModels, fileName: testFileName, packageName: packageName).render().formatted(with: IndentationFormatter.self)
        
        // empty test file
//        let testFile = templateContentWithFileComment(.testFile, alternativeFileName: testFileName)
//            .with(packageName: packageName)
        
        try (testsTarget + testFileName).write(testFile)
        
        let manifests = templateContentWithFileComment(.xCTestManifests).with(packageName: packageName)
        try (testsTarget + .xCTestManifests).write(manifests)
        let linuxMain = readTemplate(.linuxMain)
        
        try (tests + .linuxMain).write(linuxMain.formatted(with: IndentationFormatter.self))
    }
    
    private func writeTests2() throws {
        let tests = directories.tests
        let testsTarget = directories.testsTarget
        let testFileName = packageName + "Tests" + .swift
        let testFile = templateContentWithFileComment(.testFile, alternativeFileName: testFileName)
            .with(packageName: packageName)
        try (testsTarget + testFileName).write(testFile)
        
        let manifests = templateContentWithFileComment(.xCTestManifests).with(packageName: packageName)
        try (testsTarget + .xCTestManifests).write(manifests)
        let linuxMain = readTemplate(.linuxMain)
        
        try (tests + .linuxMain).write(linuxMain.formatted(with: IndentationFormatter.self))
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
