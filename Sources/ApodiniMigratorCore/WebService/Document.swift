//
//  Document.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public struct MetaData: Value {
    /// Server path
    var serverPath: String
    /// Version
    public var version: Version
    /// Encoder configuration
    public var encoderConfiguration: EncoderConfiguration
    /// Decoder configuration
    public var decoderConfiguration: DecoderConfiguration
    
    /// Server path appending the description of the version
    public var versionedServerPath: String {
        serverPath + "/" + version.description
    }
    
    init() {
        serverPath = ""
        version = .default
        encoderConfiguration = .default
        decoderConfiguration = .default
    }
    
    init(serverPath: String, version: Version, encoderConfiguration: EncoderConfiguration, decoderConfiguration: DecoderConfiguration) {
        self.serverPath = serverPath
        self.version = version
        self.encoderConfiguration = encoderConfiguration
        self.decoderConfiguration = decoderConfiguration
    }
}

public struct Document: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case id, metaData = "info", endpoints, components
    }
    
    /// Id of the document
    public let id: UUID
    
    /// Metadata
    public var metaData: MetaData
    /// Endpoints
    public var endpoints: [Endpoint]
    
    /// Name of the file, constructed as `api_{version}`
    public var fileName: String {
        "api_\(metaData.version.string.without("_"))"
    }
    
    /// Initializes an empty document
    public init() {
        id = .init()
        metaData = .init()
        endpoints = []
    }
    
    /// Adds a new enpoint
    public mutating func add(endpoint: Endpoint) {
        endpoints.append(endpoint)
    }

    /// Sets the server path to metadata
    public mutating func setServerPath(_ path: String) {
        metaData.serverPath = path
    }
    
    /// Sets the version to metadata
    public mutating func setVersion(_ version: Version) {
        metaData.version = version
    }
    
    /// Sets coder configurations to metada
    public mutating func setCoderConfigurations(
        _ encoderConfiguration: EncoderConfiguration,
        _ decoderConfiguration: DecoderConfiguration
    ) {
        metaData.encoderConfiguration = encoderConfiguration
        metaData.decoderConfiguration = decoderConfiguration
    }
    
    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(metaData, forKey: .metaData)
        var typesStore = TypesStore()
        
        let referencedEndpoints: [Endpoint] = endpoints.map {
            var endpoint = $0
            endpoint.reference(in: &typesStore)
            return endpoint
        }
        
        try container.encode(referencedEndpoints, forKey: .endpoints)
        try container.encode(typesStore.storage, forKey: .components)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        metaData = try container.decode(MetaData.self, forKey: .metaData)
        
        var typesStore = TypesStore()
        typesStore.storage = try container.decode([String: TypeInformation].self, forKey: .components)
        
        let endpoints = try container.decode([Endpoint].self, forKey: .endpoints)
        self.endpoints = endpoints.map {
            var endpoint = $0
            endpoint.dereference(in: &typesStore)
            return endpoint
        }
    }
    
    public func allModels() -> [TypeInformation] {
        endpoints.reduce(into: Set<TypeInformation>()) { result, current in
            result.insert(current.response)
            current.parameters.forEach { parameter in
                result.insert(parameter.typeInformation)
            }
        }
        .asArray
        .fileRenderableTypes()
        .sorted(by: \.typeName)
    }
}
