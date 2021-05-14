import Foundation

public struct Document: Codable {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case version, endpoints, components
    }
    
    public var version: Version
    public var endpoints: [Endpoint]
    private var typesStore: TypesStore
    
    /// Initializes an empty document
    public init() {
        version = .default
        endpoints = []
        typesStore = TypesStore()
    }
    
    
    public mutating func add(endpoint: Endpoint) {
        endpoints.append(endpoint)
    }
    
    public mutating func reference(_ typeInformation: TypeInformation) -> TypeInformation {
        typesStore.store(typeInformation)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(endpoints, forKey: .endpoints)
        try container.encode(typesStore.storage, forKey: .components)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Version.self, forKey: .version)
        endpoints = try container.decode([Endpoint].self, forKey: .endpoints)
        typesStore = TypesStore()
        typesStore.storage = try container.decode([String: TypeInformation].self, forKey: .components)
    }
    
    public func export(at path: Path) throws {
        try path.write(json)
    }
}
