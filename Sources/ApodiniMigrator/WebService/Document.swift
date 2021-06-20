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
}

public struct Document: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case metaData = "info", endpoints, components
    }
    
    /// Metadata
    public var metaData: MetaData
    /// Endpoints
    public var endpoints: [Endpoint]
    
    /// Initializes an empty document
    public init() {
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
    
    /// Exports json representation of self at the specified path
    public func export(at path: String) throws {
        try Path(path).write(json)
    }
}
