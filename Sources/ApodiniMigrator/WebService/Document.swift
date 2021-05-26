import Foundation
import ApodiniMigratorShared

public struct MetaData: Value {
    public var serverPath: String
    public var version: Version
    public var encoderConfiguration: EncoderConfiguration
    public var decoderConfiguration: DecoderConfiguration
    
    public var versionedServerPath: String {
        serverPath + "/" + version.description
    }
    
    init() {
        serverPath = ""
        version = .default
        encoderConfiguration = .default
        decoderConfiguration = .default
    }
}

public struct Document: Value { // TODO handle referencing in encode and init from decoder
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case metaData = "info", endpoints, components
    }
    
    public var metaData: MetaData
    public var endpoints: [Endpoint]
    
    /// Initializes an empty document
    public init() {
        metaData = .init()
        endpoints = []
    }
    
    public mutating func add(endpoint: Endpoint) {
        endpoints.append(endpoint)
    }

    public mutating func setServerPath(_ path: String) {
        metaData.serverPath = path
    }
    
    public mutating func setVersion(_ version: Version) {
        metaData.version = version
    }
    
    public mutating func setCoderConfigurations(
        _ encoderConfiguration: EncoderConfiguration,
        _ decoderConfiguration: DecoderConfiguration
    ) {
        metaData.encoderConfiguration = encoderConfiguration
        metaData.decoderConfiguration = decoderConfiguration
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
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
    
    public func export(at path: Path) throws {
        try path.write(json)
    }
}
