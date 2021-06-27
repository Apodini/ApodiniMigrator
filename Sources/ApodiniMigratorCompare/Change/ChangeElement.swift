//
//  ChangeElement.swift
//  
//
//  Created by Eldi Cano on 22.05.21.
//

import Foundation
import ApodiniMigrator

public enum ElementType: String, Value {
    case endpoint
    case `enum`
    case object
    case networking
}

/// Represents distinct top-level elements that are subject to change in the web service
public enum ChangeElement: DeltaIdentifiable, Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case endpoint, `enum`, object, networking, target
    }
    
    /// Represents an endpoint change element identified by its id and the corresponding endpoint change target
    case endpoint(DeltaIdentifier, target: EndpointTarget)
    /// An internal convenience static method to return an `.endpoint` change element with its corresponding target
    static func `for`(endpoint: Endpoint, target: EndpointTarget) -> ChangeElement {
        .endpoint(endpoint.deltaIdentifier, target: target)
    }
    
    /// Represents an enum change element identified by its id and the corresponding enum change target
    case `enum`(DeltaIdentifier, target: EnumTarget)
    /// An internal convenience static method to return an `.enum` change element with its corresponding target
    static func `for`(enum: TypeInformation, target: EnumTarget) -> ChangeElement {
        .enum(`enum`.deltaIdentifier, target: target)
    }
    
    /// Represents an object change element identified by its id and the corresponding object change target
    case object(DeltaIdentifier, target: ObjectTarget)
    /// An internal convenience static method to return an `.object` change element with its corresponding target
    static func `for`(object: TypeInformation, target: ObjectTarget) -> ChangeElement {
        .object(object.deltaIdentifier, target: target)
    }
    
    /// Represents an networking change element and the corresponding networking change target
    /// - Note: Networking change element always have `DeltaIdentifier("NetworkingService")` as id
    case networking(target: NetworkingTarget)
    
    /// Encodes `self` into the given encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let key: CodingKeys
        switch self {
        case .endpoint: key = .endpoint
        case .enum: key = .enum
        case .object: key = .object
        case .networking: key = .networking
        }
        try container.encode(deltaIdentifier, forKey: key)
        try container.encode(target, forKey: .target)
    }
    
    /// Creates a new instance by decoding from the given decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = container.allKeys
        
        if keys.contains(.endpoint) {
            let target = try container.decode(EndpointTarget.self, forKey: .target)
            self = .endpoint(try container.decode(DeltaIdentifier.self, forKey: .endpoint), target: target)
        } else if keys.contains(.enum) {
            let target = try container.decode(EnumTarget.self, forKey: .target)
            self = .enum(try container.decode(DeltaIdentifier.self, forKey: .enum), target: target)
        } else if keys.contains(.object) {
            let target = try container.decode(ObjectTarget.self, forKey: .target)
            self = .object(try container.decode(DeltaIdentifier.self, forKey: .object), target: target)
        } else if keys.contains(.networking) {
            let target = try container.decode(NetworkingTarget.self, forKey: .target)
            self = .networking(target: target)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: keys, debugDescription: "Failed to decode \(Self.self)"))
        }
    }
}

// MARK: - ChangeElement
public extension ChangeElement {
    /// Returns the delta identifier of the change element
    var deltaIdentifier: DeltaIdentifier {
        switch self {
        case let .endpoint(deltaIdentifier, _): return deltaIdentifier
        case let .enum(deltaIdentifier, _): return deltaIdentifier
        case let .object(deltaIdentifier, _): return deltaIdentifier
        case .networking: return .init("NetworkingService")
        }
    }
    
    /// Returns the corresponding string raw value of the target of `self`
    var target: String {
        switch self {
        case let .endpoint(_, target): return target.rawValue
        case let .enum(_, target): return target.rawValue
        case let .object(_, target): return target.rawValue
        case let .networking(target): return target.rawValue
        }
    }
    
    var type: ElementType {
        switch self {
        case .endpoint: return .endpoint
        case .enum: return .enum
        case .object: return .object
        case .networking: return .networking
        }
    }
    
    /// Indicates whether `self` is an `.endpoint` change element
    var isEndpoint: Bool {
        type == .endpoint
    }
    
    /// Indicates whether `self` is an `.enum` change element
    var isEnum: Bool {
        type == .enum
    }
    
    /// Indicates whether `self` is an `.object` change element
    var isObject: Bool {
        type == .object
    }
    
    /// Indicates whether `self` is an `.networking` change element
    var isNetworking: Bool {
        type == .networking
    }
}
