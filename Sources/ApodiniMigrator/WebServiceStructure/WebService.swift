import Foundation

/// Holds the list of all registered endpoints and all schemas
struct WebService {
    /// Version of the web service
    var version: Version = .default

    /// Services
    var services: [Endpoint] = []

    /// Schema builder object
    var schemaBuilder = SchemaBuilder()

    /// Schemas built by the schema builder
    var schemas: [Schema] { Array(schemaBuilder.schemas) }
}

// MARK: - Codable
extension WebService: Codable {
    private enum CodingKeys: String, CodingKey {
        case version
        case services
        case schemas
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(services, forKey: .services)
        try container.encode(schemaBuilder.schemas, forKey: .schemas)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(Version.self, forKey: .version)
        services = try container.decode([Endpoint].self, forKey: .services)
        let schemas = try container.decode(Set<Schema>.self, forKey: .schemas)
        schemaBuilder = SchemaBuilder()
        schemaBuilder.addSchemas(schemas)
    }
}

// MARK: - ComparableObject
extension WebService: ComparableObject {
    var deltaIdentifier: DeltaIdentifier {
        .init(version.description)
    }

    func evaluate(result: ChangeContextNode, embeddedInCollection: Bool) -> Change? {
        let changes = [
            services.evaluate(node: result),
            schemas.evaluate(node: result)
        ].compactMap { $0 }

        guard !changes.isEmpty else {
            return nil
        }

        return .compositeChange(location: Self.changeLocation, changes: changes)
    }

    func compare(to other: WebService) -> ChangeContextNode {
        ChangeContextNode()
            .register(result: compare(\.services, with: other), for: Endpoint.self)
            .register(result: compare(\.schemas, with: other), for: Schema.self)
    }

    // Required from ComparableObject protocol, however not used for WebService
    static func == (lhs: WebService, rhs: WebService) -> Bool { false }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(deltaIdentifier.rawValue)
    }
}
