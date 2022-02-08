//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCore

/// Represents distinct top-level elements that are subject to change in the web service
enum LegacyChangeElement: Decodable {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case endpoint, `enum`, object, networking, target
    }
    
    /// Represents an endpoint change element identified by its id and the corresponding endpoint change target
    case endpoint(DeltaIdentifier, target: LegacyEndpointTarget)
    
    /// Represents an enum change element identified by its id and the corresponding enum change target
    case `enum`(DeltaIdentifier, target: LegacyEnumTarget)
    
    /// Represents an object change element identified by its id and the corresponding object change target
    case object(DeltaIdentifier, target: LegacyObjectTarget)
    
    /// Represents an networking change element and the corresponding networking change target
    /// - Note: Networking change element always have `DeltaIdentifier("NetworkingService")` as id
    case networking(target: LegacyNetworkingTarget)
    
    /// Creates a new instance by decoding from the given decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = container.allKeys
        
        if keys.contains(.endpoint) {
            let target = try container.decode(LegacyEndpointTarget.self, forKey: .target)
            self = .endpoint(try container.decode(DeltaIdentifier.self, forKey: .endpoint), target: target)
        } else if keys.contains(.enum) {
            let target = try container.decode(LegacyEnumTarget.self, forKey: .target)
            self = .enum(try container.decode(DeltaIdentifier.self, forKey: .enum), target: target)
        } else if keys.contains(.object) {
            let target = try container.decode(LegacyObjectTarget.self, forKey: .target)
            self = .object(try container.decode(DeltaIdentifier.self, forKey: .object), target: target)
        } else if keys.contains(.networking) {
            let target = try container.decode(LegacyNetworkingTarget.self, forKey: .target)
            self = .networking(target: target)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: keys, debugDescription: "Failed to decode \(Self.self)"))
        }
    }
}

// MARK: - ChangeElement
extension LegacyChangeElement {
    /// Returns the delta identifier of the change element
    var deltaIdentifier: DeltaIdentifier {
        switch self {
        case let .endpoint(deltaIdentifier, _): return deltaIdentifier
        case let .enum(deltaIdentifier, _): return deltaIdentifier
        case let .object(deltaIdentifier, _): return deltaIdentifier
        case .networking: return "NetworkingService"
        }
    }
}
