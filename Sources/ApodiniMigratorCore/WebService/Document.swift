//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

public struct HTTPServerConfiguration {
    enum Version {
        case http1
        case http1_1
        case http2
    }

    var hostname: String
    var port: Int
    var version: Self.Version
    var secure: Bool // TODO toggles SSL?
    // TODO other stuff like base url?
}

/// General Information about the web service.
public struct ServiceInformation: Value {
    // TODO severPath shouldn't be already assembled!
    /// Server path
    var serverPath: String
    /// Version
    public var version: Version
    /// Encoder configuration
    public var encoderConfiguration: EncoderConfiguration // TODO this is exporter specific configuration!!
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
        case id
        case documentVersion = "v" // TODO that short key?
        case metaData = "info"
        case endpoints
        case components
    }
    
    /// Id of the document
    public let id: UUID

    /// Describes the version the ``Document`` was generate with
    public let documentVersion: DocumentVersion
    
    /// Metadata
    public var metaData: ServiceInformation // TODO can we rename that?
    // TODO ideally the document would include a "ExporterInformation" section providing infos about each and every configured exporter!
    // TODO => command line flag to configure exporter would then check if there is a configuration => if there was any exporter at all!
    /// Endpoints
    public var endpoints: [Endpoint]
    
    /// Name of the file, constructed as `api_{version}`
    public var fileName: String {
        "api_\(metaData.version.string.without("_"))"
    }
    
    /// Initializes an empty document
    public init() {
        id = .init()
        documentVersion = .v2
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
        try container.encode(documentVersion, forKey: .documentVersion)
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
        documentVersion = try container.decodeIfPresent(DocumentVersion.self, forKey: .documentVersion) ?? .v1

        // TODO old version
        /*
        guard case .v2 = documentVersion else {
            // TODO use maybe some custom error or so!!
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: """
                                  The Migrator API document was created with an outdated version (\(documentVersion)) and isn't \
                                  supported by the current document version \(DocumentVersion.v2)
                                  """
            ))
        }
        */

        id = try container.decode(UUID.self, forKey: .id)
        metaData = try container.decode(ServiceInformation.self, forKey: .metaData)

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

public enum DocumentVersion: String, Codable {
    // TODO make this more SemVer style (e.g. allow shorter versions strings e.g. "1" => "1.0.0"
    case v1 = "1.0.0"
    case v2 = "2.0.0"
}
