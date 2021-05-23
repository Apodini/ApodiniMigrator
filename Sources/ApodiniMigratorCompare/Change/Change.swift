//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

public enum ChangedValue: Codable {
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
    
    static func jsonString<E: Encodable>(_ encodable: E) -> ChangedValue {
        .json(encodable.json)
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

protocol Change: Codable {
    var element: ChangeElement { get }
    var target: ChangeTarget { get }
}

struct AddChange: Change {
    var element: ChangeElement
    var target: ChangeTarget
    
    var added: ChangedValue
    var defaultValue: ChangedValue
}

struct RenameChange: Change {
    var element: ChangeElement
    var target: ChangeTarget
    
    var from: String
    var to: String
}

struct ValueChange: Change {
    var element: ChangeElement
    var target: ChangeTarget
    
    var from: ChangedValue
    var to: ChangedValue
}

struct DeleteChange: Change {
    var element: ChangeElement
    var target: ChangeTarget
    
    var deleted: ChangedValue
    var fallbackValue: ChangedValue
}

struct TypeChange: Change {
    var element: ChangeElement
    var target: ChangeTarget
    
    var identifier: DeltaIdentifier
    
    var from: TypeInformation
    var to: TypeInformation
    
    func convertTo() -> String {
        "" // Some js function to convert from to
    }
    
    func convertFrom() -> String {
        "" // some js function to convert to from
    }
}
