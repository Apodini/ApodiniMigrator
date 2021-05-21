import Foundation
import ApodiniMigratorShared

public struct MetaData: Codable {
    public var serverPath: String
    public var version: Version
    public var encoderConfiguration: EncoderConfiguration
    public var decoderConfiguration: DecoderConfiguration
    
    init() {
        serverPath = ""
        version = .default
        encoderConfiguration = .default
        decoderConfiguration = .default
    }
}

public struct Document: Codable { // TODO handle referencing in encode and init from decoder
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case metaData = "info", endpoints, components
    }
    
    public var metaData: MetaData
    public var endpoints: [Endpoint]
    private var typesStore: TypesStore
    
    /// Initializes an empty document
    public init() {
        metaData = .init()
        endpoints = []
        typesStore = TypesStore()
    }
    
    public mutating func add(endpoint: Endpoint) {
        endpoints.append(endpoint)
    }
    
    public mutating func dereference() {
        endpoints = endpoints.map {
            var endpoint = $0
            endpoint.dereference(in: &typesStore)
            return endpoint
        }
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
    
    public mutating func reference(_ typeInformation: TypeInformation) -> TypeInformation {
        typesStore.store(typeInformation)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(endpoints, forKey: .endpoints)
        try container.encode(typesStore.storage, forKey: .components)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metaData = try container.decode(MetaData.self, forKey: .metaData)
        endpoints = try container.decode([Endpoint].self, forKey: .endpoints)
        typesStore = TypesStore()
        typesStore.storage = try container.decode([String: TypeInformation].self, forKey: .components)
    }
    
    public func export(at path: Path) throws {
        try path.write(json)
    }
}
