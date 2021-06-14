//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

public enum ChangeValue: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case none, id, string, json
    }
    case none
    case id(DeltaIdentifier)
    case string(String)
    case json(String)
    
    public var value: String {
        switch self {
        case .none: return "none"
        case let .id(id): return id.rawValue
        case let .string(string): return string
        case let .json(string): return string
        }
    }
    
    public var isNone: Bool {
        self == .none
    }
    
    public var isID: Bool {
        if case .id = self {
            return true
        }
        return false
    }
    
    public var isString: Bool {
        if case .string = self {
            return true
        }
        return false
    }
    
    public var isJSON: Bool {
        if case .json = self {
            return true
        }
        return false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .none: try container.encode(value, forKey: .none)
        case .id: try container.encode(value, forKey: .id)
        case .string: try container.encode(value, forKey: .string)
        case .json: try container.encode(value, forKey: .json)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode \(Self.self)"))
        }
        
        switch key {
        case .none: self = .none
        case .id: self = .id(try container.decode(DeltaIdentifier.self, forKey: .id))
        case .string: self = .string(try container.decode(String.self, forKey: .string))
        case .json: self = .json(try container.decode(String.self, forKey: .json))
        }
    }
}

extension ChangeValue {
    /// Returns .json representation of an encodable value
    /// Used for passing added or deleted elements of web service
    static func json<E: Encodable>(of encodable: E) -> ChangeValue {
        .json(encodable.json)
    }
    
    /// Returns a valid json string out of the type information with empty values
    /// Used for providing default or fallbackValues for elements that require it
    static func value(from typeInformation: TypeInformation, with configuration: EncoderConfiguration) -> ChangeValue {
        .json(JSONStringBuilder.jsonString(typeInformation, with: configuration))
    }
    
    static func id<D: DeltaIdentifiable>(from identifiable: D) -> ChangeValue {
        .id(identifiable.deltaIdentifier)
    }
}

public extension Decodable {
    static func decode(from changeValue: ChangeValue) throws -> Self {
        guard changeValue.isJSON else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Can't decode from a `ChangeValue` that is not json"))
        }
        return try Self.decode(from: changeValue.value)
    }
}
