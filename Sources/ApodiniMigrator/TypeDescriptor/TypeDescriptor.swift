import Foundation

enum TypeDescriptor: Value {
    case scalar(PrimitiveType)
    indirect case array(element: TypeDescriptor)
    indirect case dictionary(key: PrimitiveType, value: TypeDescriptor)
    indirect case optional(wrappedValue: TypeDescriptor)
    case `enum`(name: TypeName, cases: [EnumCase])
    case object(name: TypeName, properties: [TypeProperty])
}

// MARK: - TypeDescriptor + Equatable
extension TypeDescriptor {
    static func == (lhs: TypeDescriptor, rhs: TypeDescriptor) -> Bool {
        if !lhs.sameType(with: rhs) {
            return false
        }
        
        switch (lhs, rhs) {
        case let (.scalar(lhsPrimitiveType), .scalar(rhsPrimitiveType)):
            return lhsPrimitiveType == rhsPrimitiveType
        case let (.array(lhsElement), .array(rhsElement)):
            return lhsElement == rhsElement
        case let (.dictionary(lhsKey, lhsValue), .dictionary(rhsKey, rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        case let (.optional(lhsWrappedValue), .optional(rhsWrappedValue)):
            return lhsWrappedValue == rhsWrappedValue
        case let (.enum(lhsName, lhsCases), .enum(rhsName, rhsCases)):
            return lhsName == rhsName && lhsCases.equalsIgnoringOrder(to: rhsCases)
        case let (.object(lhsName, lhsProperties), .object(rhsName, rhsProperties)):
            return lhsName == rhsName && lhsProperties.equalsIgnoringOrder(to: rhsProperties)
        default: return false
        }
    }
}

// MARK: - TypeDescriptor + Codable
extension TypeDescriptor {
    // MARK: CodingKeys
    private enum CodingKeys: String, CodingKey {
        case scalar, array, dictionary, optional, `enum`, object
    }
    
    private enum DictionaryKeys: String, CodingKey {
        case key, value
    }
    
    private enum EnumKeys: String, CodingKey {
        case typeName, cases
    }
    
    private enum ObjectKeys: String, CodingKey {
        case typeName, properties
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .scalar(primitiveType): try container.encode(primitiveType, forKey: .scalar)
        case let .array(element): try container.encode(element, forKey: .array)
        case let .dictionary(key, value):
            var dictionaryContainer = container.nestedContainer(keyedBy: DictionaryKeys.self, forKey: .dictionary)
            try dictionaryContainer.encode(key, forKey: .key)
            try dictionaryContainer.encode(value, forKey: .value)
        case let .optional(wrappedValue): try container.encode(wrappedValue, forKey: .optional)
        case let .enum(name, cases):
            var enumContainer = container.nestedContainer(keyedBy: EnumKeys.self, forKey: .enum)
            try enumContainer.encode(name, forKey: .typeName)
            try enumContainer.encode(cases, forKey: .cases)
        case let .object(name, properties):
            var objectContainer = container.nestedContainer(keyedBy: ObjectKeys.self, forKey: .object)
            try objectContainer.encode(name, forKey: .typeName)
            try objectContainer.encode(properties, forKey: .properties)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .scalar: self = .scalar(try container.decode(PrimitiveType.self, forKey: .scalar))
        case .array: self = .array(element: try container.decode(TypeDescriptor.self, forKey: .array))
        case .optional: self = .optional(wrappedValue: try container.decode(TypeDescriptor.self, forKey: .optional))
        case .dictionary:
            let dictionaryContainer = try container.nestedContainer(keyedBy: DictionaryKeys.self, forKey: .dictionary)
            self = .dictionary(
                key: try dictionaryContainer.decode(PrimitiveType.self, forKey: .key),
                value: try dictionaryContainer.decode(TypeDescriptor.self, forKey: .value)
            )
        case .enum:
            let enumContainer = try container.nestedContainer(keyedBy: EnumKeys.self, forKey: .enum)
            let name = try enumContainer.decode(TypeName.self, forKey: .typeName)
            let cases = try enumContainer.decode([EnumCase].self, forKey: .cases)
            self = .enum(name: name, cases: cases)
        case .object:
            let objectContainer = try container.nestedContainer(keyedBy: ObjectKeys.self, forKey: .object)
            self = .object(
                name: try objectContainer.decode(TypeName.self, forKey: .typeName),
                properties: try objectContainer.decode([TypeProperty].self, forKey: .properties)
            )
        default: fatalError("Failed to decode type container")
        }
    }
}

extension TypeDescriptor: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        json
    }
    
    var debugDescription: String {
        json
    }
}
