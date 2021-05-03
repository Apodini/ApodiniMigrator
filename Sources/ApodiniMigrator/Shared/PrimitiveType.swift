import Foundation

/// Whether the type is a supported scalar type
public func isSupportedScalarType(_ type: Any.Type) -> Bool {
    PrimitiveType(type) != nil
}

public enum PrimitiveType: String, RawRepresentable, CaseIterable, ComparableProperty, CustomStringConvertible {
    case bool = "Bool"
    case int = "Int"
    case int8 = "Int8"
    case int16 = "Int16"
    case int32 = "Int32"
    case int64 = "Int64"
    case uint = "UInt"
    case uint8 = "UInt8"
    case uint16 = "UInt16"
    case uint32 = "UInt32"
    case uint64 = "UInt64"
    case string = "String"
    case double = "Double"
    case float = "Float"
    case uuid = "UUID"
    case date = "Date"
    case data = "Data"

    public var description: String { rawValue }
    
    public init?(_ type: Any.Type) {
        if let primitiveType = PrimitiveType(rawValue: "\(type)") {
            self = primitiveType
        } else {
            return nil
        }
    }
    
    var swiftType: DefaultInitializable.Type {
        switch self {
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
        case .uuid: return UUID.self
        case .date: return Date.self
        case .data: return Data.self
        }
    }
}

extension PrimitiveType {
    var typeName: TypeName {
        .init(swiftType)
    }
}
