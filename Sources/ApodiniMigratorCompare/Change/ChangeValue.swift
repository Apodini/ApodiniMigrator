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
        case none, string, json
    }
    case none
    case string(String)
    case json(String)
    
    var value: String {
        switch self {
        case .none: return "none"
        case let .string(string): return string
        case let .json(string): return string
        }
    }
    
    /// Returns .json representation of an encodable value
    static func jsonString<E: Encodable>(_ encodable: E) -> ChangeValue {
        .json(encodable.json)
    }
    
    /// Returns a valid json string out of the type information with empty values
    static func json(_ typeInformation: TypeInformation) -> ChangeValue {
        .json(JSONStringBuilder.jsonString(typeInformation))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .none: try container.encode(value, forKey: .none)
        case .string: try container.encode(value, forKey: .string)
        case .json: try container.encode(value, forKey: .json)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let key = container.allKeys.first else {
            fatalError("Failed to decode \(Self.self)")
        }
        
        switch key {
        case .none: self = .none
        case .string: self = .string(try container.decode(String.self, forKey: .string))
        case .json: self = .json(try container.decode(String.self, forKey: .json))
        }
    }
}
