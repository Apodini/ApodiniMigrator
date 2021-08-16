//
//  PrimitiveType.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents distinct cases of scalar types (JSON values)
public enum ScalarType: String, RawRepresentable, CaseIterable, Value {
    /// Null
    case null
    /// Boolean
    case bool
    /// String
    case string
    /// Number
    case number
    /// Unsigned number
    case unsignedNumber
    /// Float
    case float
    
    /// A representing primitive type of `self`
    public var representation: PrimitiveType {
        switch self {
        case .null: return .null
        case .bool: return .bool
        case .string: return .string
        case .number: return .int64
        case .unsignedNumber: return .uint64
        case .float: return .float
        }
    }
}

/// Represents different cases of primitive types
public enum PrimitiveType: String, RawRepresentable, CaseIterable, Value {
    /// Null (NSNull)
    case null
    /// Bool
    case bool
    /// Int
    case int
    /// Int8
    case int8
    /// Int16
    case int16
    /// Int32
    case int32
    /// Int64
    case int64
    /// UInt
    case uint
    /// UInt8
    case uint8
    /// UInt16
    case uint16
    /// UInt32
    case uint32
    /// UInt64
    case uint64
    /// String
    case string
    /// Double
    case double
    /// Float
    case float
    /// URL
    case url
    /// UUID
    case uuid
    /// Date
    case date
    /// Data
    case data
    
    /// Initializes `self` out of an `Any.Type` if `type` corresponds to one of `PrimitiveType` cases, otherwise returns nil
    public init?(_ type: Any.Type) {
        if type == Null.self || type == NSNull.self {
            self = .null
        } else if type == Bool.self {
            self = .bool
        } else if type == Int.self {
            self = .int
        } else if type == Int8.self {
            self = .int8
        } else if type == Int16.self {
            self = .int16
        } else if type == Int32.self {
            self = .int32
        } else if type == Int64.self {
            self = .int64
        } else if type == UInt.self {
            self = .uint
        } else if type == UInt8.self {
            self = .uint8
        } else if type == UInt16.self {
            self = .uint16
        } else if type == UInt32.self {
            self = .uint32
        } else if type == UInt64.self || type == Decimal.self || type == NSDecimalNumber.self {
            self = .uint64
        } else if type == String.self || type == NSString.self {
            self = .string
        } else if type == Double.self {
            self = .double
        } else if type == Float.self {
            self = .float
        } else if type == NSURL.self || type == URL.self {
            self = .url
        } else if type == UUID.self {
            self = .uuid
        } else if type == NSDate.self || type == Date.self {
            self = .date
        } else if type == Data.self || type == NSData.self {
            self = .url
        } else {
            return nil
        }
    }
    
    /// Corresponding `Swift` type of the instance
    public var swiftType: DefaultInitializable.Type {
        switch self {
        case .null: return Null.self
        case .bool: return Bool.self
        case .int: return Int.self
        case .int8: return Int8.self
        case .int16: return Int16.self
        case .int32: return Int32.self
        case .int64: return Int64.self
        case .uint: return UInt.self
        case .uint8: return UInt8.self
        case .uint16: return UInt16.self
        case .uint32: return UInt32.self
        case .uint64: return UInt64.self
        case .string: return String.self
        case .double: return Double.self
        case .float: return Float.self
        case .url: return URL.self
        case .uuid: return UUID.self
        case .date: return Date.self
        case .data: return Data.self
        }
    }
    
    /// `TypeName` instance of `self` (`swiftType`)
    public var typeName: TypeName {
        .init(swiftType)
    }
    
    /// Encodes `self` value into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let pritimitiveType = Self(rawValue: try container.decode(String.self).lowercased()) {
            self = pritimitiveType
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode \(Self.self)")
        }
    }
    
    public var scalarType: ScalarType {
        switch self {
        case .null: return .null
        case .bool: return .bool
        case .int, .int8, .int16, .int32, .int64: return .number
        case .uint, .uint8, .uint16, .uint32, .uint64: return .unsignedNumber
        case .string, .uuid, .url, .data: return .string
        case .double, .float, .date: return .float
        }
    }
}

// MARK: - CustomStringConvertible + CustomDebugStringConvertible
extension PrimitiveType: CustomStringConvertible, CustomDebugStringConvertible {
    /// Textual representation of an instance
    public var description: String { String(describing: swiftType) }
    /// Textual representation of an instance
    public var debugDescription: String { description }
}
