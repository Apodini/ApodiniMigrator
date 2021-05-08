import Foundation

/// Holds the list of all registered endpoints
struct WebService {
    /// Version of the web service
    var version: Version = .default

    /// Services
    var services: [Endpoint] = []
}

// MARK: - Codable
extension WebService: Codable {
    private enum CodingKeys: String, CodingKey {
        case version
        case services
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(services, forKey: .services)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(Version.self, forKey: .version)
        services = try container.decode([Endpoint].self, forKey: .services)
    }
}

// MARK: - ComparableObject
extension WebService: ComparableObject {
    var deltaIdentifier: DeltaIdentifier {
        .init(version.description)
    }

    func evaluate(result: ChangeContextNode, embeddedInCollection: Bool) -> Change? {
        let changes = [
            services.evaluate(node: result)
        ].compactMap { $0 }

        guard !changes.isEmpty else {
            return nil
        }

        return .compositeChange(location: Self.changeLocation, changes: changes)
    }

    func compare(to other: WebService) -> ChangeContextNode {
        ChangeContextNode()
            .register(result: compare(\.services, with: other), for: Endpoint.self)
    }

    // Required from ComparableObject protocol, however not used for WebService
    static func == (lhs: WebService, rhs: WebService) -> Bool { false }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(deltaIdentifier.rawValue)
    }
}
