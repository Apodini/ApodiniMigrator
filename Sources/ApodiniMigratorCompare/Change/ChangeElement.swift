//
//  File.swift
//  
//
//  Created by Eldi Cano on 22.05.21.
//

import Foundation
import ApodiniMigrator

enum ChangeElement: DeltaIdentifiable, Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case endpoint, `enum`, object, networking, target
    }
    
    case endpoint(DeltaIdentifier, target: EndpointTarget)
    case `enum`(DeltaIdentifier, target: EnumTarget)
    case object(DeltaIdentifier, target: ObjectTarget)
    case networking(target: NetworkingTarget)
    
    var target: String {
        switch self {
        case let .endpoint(_, target): return target.rawValue
        case let .enum(_, target): return target.rawValue
        case let .object(_, target): return target.rawValue
        case let .networking(target): return target.rawValue
        }
    }
    
    var isEndpoint: Bool {
        if case .endpoint = self {
            return true
        }
        return false
    }
    
    var isEnum: Bool {
        if case .enum = self {
            return true
        }
        return false
    }
    
    var isObject: Bool {
        if case .object = self {
            return true
        }
        return false
    }
    
    var isNetworking: Bool {
        if case .networking = self {
            return true
        }
        return false
    }
    
    var deltaIdentifier: DeltaIdentifier {
        switch self {
        case let .endpoint(deltaIdentifier, _): return deltaIdentifier
        case let .enum(deltaIdentifier, _): return deltaIdentifier
        case let .object(deltaIdentifier, _): return deltaIdentifier
        case .networking: return .init("NetworkingService")
        }
    }
    
    func encode(to encoder: Encoder) throws {
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
    
    init(from decoder: Decoder) throws {
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
    
    static func `for`(endpoint: Endpoint, target: EndpointTarget) -> ChangeElement {
        .endpoint(endpoint.deltaIdentifier, target: target)
    }
    
    static func `for`(object: TypeInformation, target: ObjectTarget) -> ChangeElement {
        return .object(object.deltaIdentifier, target: target)
    }
    
    static func `for`(enum: TypeInformation, target: EnumTarget) -> ChangeElement {
        return .enum(`enum`.deltaIdentifier, target: target)
    }
}

