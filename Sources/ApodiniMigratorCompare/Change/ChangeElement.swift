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
        case endpoint, `enum`, object, networking
    }
    
    case endpoint(DeltaIdentifier)
    case `enum`(DeltaIdentifier)
    case object(DeltaIdentifier)
    case networking
    
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
        case let .endpoint(deltaIdentifier): return deltaIdentifier
        case let .enum(deltaIdentifier): return deltaIdentifier
        case let .object(deltaIdentifier): return deltaIdentifier
        case .networking: return .init("NetworkingService")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .endpoint(deltaIdentifier): try container.encode(deltaIdentifier, forKey: .endpoint)
        case let .enum(deltaIdentifier): try container.encode(deltaIdentifier, forKey: .enum)
        case let .object(deltaIdentifier): try container.encode(deltaIdentifier, forKey: .object)
        case .networking: try container.encode(deltaIdentifier, forKey: .networking)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .endpoint: self = .endpoint(try container.decode(DeltaIdentifier.self, forKey: .endpoint))
        case .enum: self = .enum(try container.decode(DeltaIdentifier.self, forKey: .enum))
        case .object: self = .object(try container.decode(DeltaIdentifier.self, forKey: .object))
        case .networking: self = .networking
        default: fatalError("Failed to decode \(Self.self)")
        }
    }
}
