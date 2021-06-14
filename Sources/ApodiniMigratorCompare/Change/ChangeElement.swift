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
    
    case endpoint(DeltaIdentifier, target: ChangeTarget) // TODO review, only deltaIdentifier is enough
    case `enum`(DeltaIdentifier, target: ChangeTarget)
    case object(DeltaIdentifier, target: ChangeTarget)
    case networking(target: ChangeTarget)
    
    var target: ChangeTarget {
        switch self {
        case let .endpoint(_, target): return target
        case let .enum(_, target): return target
        case let .object(_, target): return target
        case let .networking(target): return target
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
        try container.encode(target, forKey: .target)
        switch self {
        case let .endpoint(endpointElement, _):
            try container.encode(endpointElement, forKey: .endpoint)
        case let .enum(deltaIdentifier, _):
            try container.encode(deltaIdentifier, forKey: .enum)
        case let .object(deltaIdentifier, _):
            try container.encode(deltaIdentifier, forKey: .object)
        case .networking: try container.encode(deltaIdentifier, forKey: .networking)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let target = try container.decode(ChangeTarget.self, forKey: .target)
        let key = container.allKeys.first
        switch key {
        case .endpoint: self = .endpoint(try container.decode(DeltaIdentifier.self, forKey: .endpoint), target: target)
        case .enum: self = .enum(try container.decode(DeltaIdentifier.self, forKey: .enum), target: target)
        case .object: self = .object(try container.decode(DeltaIdentifier.self, forKey: .object), target: target)
        case .networking: self = .networking(target: target)
        default: fatalError("Failed to decode \(Self.self)")
        }
    }
    
    static func `for`(endpoint: Endpoint, target: ChangeTarget) -> ChangeElement {
        .endpoint(endpoint.deltaIdentifier, target: target)
    }
    
    static func `for`(model: TypeInformation, target: ChangeTarget) -> ChangeElement {
        if model.isObject {
            return .object(model.deltaIdentifier, target: target)
        } else if model.isEnum {
            return .enum(model.deltaIdentifier, target: target)
        } else {
            fatalError("Attempted to request ChangeElement for a model that is not enum or object")
        }
    }
}

