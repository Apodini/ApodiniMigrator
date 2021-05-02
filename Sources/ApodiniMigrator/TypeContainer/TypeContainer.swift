import Foundation

enum TypeContainer: Hashable, Codable {
    case primitive(PrimitiveType)
    indirect case array(element: TypeContainer)
    indirect case dictionary(key: PrimitiveType, value: TypeContainer)
    indirect case optional(wrappedValue: TypeContainer)
    case `enum`(name: SchemaName, cases: [String])
    case complex(name: SchemaName, properties: [TypeProperty])
}

// MARK: - TypeContainer + Equatable
extension TypeContainer {
    static func == (lhs: TypeContainer, rhs: TypeContainer) -> Bool {
        switch (lhs, rhs) {
        case let (.primitive(lhsPrimitiveType), .primitive(rhsPrimitiveType)):
            return lhsPrimitiveType == rhsPrimitiveType
        case let (.array(lhsElement), .array(rhsElement)):
            return lhsElement == rhsElement
        case let (.dictionary(lhsKey, lhsValue), .dictionary(rhsKey, rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        case let (.optional(lhsWrappedValue), .optional(rhsWrappedValue)):
            return lhsWrappedValue == rhsWrappedValue
        case let (.enum(lhsName, lhsCases), .enum(rhsName, rhsCases)):
            return lhsName == rhsName && lhsCases.equalsIgnoringOrder(to: rhsCases)
        case let (.complex(lhsName, lhsProperties), .complex(rhsName, rhsProperties)):
            return lhsName == rhsName && lhsProperties.equalsIgnoringOrder(to: rhsProperties)
        default: return false
        }
    }
}

// MARK: - TypeContainer + Codable
extension TypeContainer {
    // MARK: CodingKeys
    private enum CodingKeys: String, CodingKey {
        case primitive, array, dictionary, optional, `enum`, complex
    }
    
    private enum DictionaryKeys: String, CodingKey {
        case key, value
    }
    
    private enum EnumKeys: String, CodingKey {
        case name, cases
    }
    
    private enum ComplexKeys: String, CodingKey {
        case name, properties
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .primitive(primitiveType):
            try container.encode(primitiveType, forKey: .primitive)
        case let .array(element):
            try container.encode(element, forKey: .array)
        case let .dictionary(key, value):
            var dictionaryContainer = container.nestedContainer(keyedBy: DictionaryKeys.self, forKey: .dictionary)
            try dictionaryContainer.encode(key, forKey: .key)
            try dictionaryContainer.encode(value, forKey: .value)
        case let .optional(wrappedValue):
            try container.encode(wrappedValue, forKey: .optional)
        case let .enum(name, cases):
            var enumContainer = container.nestedContainer(keyedBy: EnumKeys.self, forKey: .enum)
            try enumContainer.encode(name, forKey: .name)
            try enumContainer.encode(cases, forKey: .cases)
        case let .complex(name, properties):
            var complexContainer = container.nestedContainer(keyedBy: ComplexKeys.self, forKey: .complex)
            try complexContainer.encode(name, forKey: .name)
            try complexContainer.encode(properties, forKey: .properties)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .primitive: self = .primitive(try container.decode(PrimitiveType.self, forKey: .primitive))
        case .array: self = .array(element: try container.decode(TypeContainer.self, forKey: .array))
        case .optional: self = .optional(wrappedValue: try container.decode(TypeContainer.self, forKey: .optional))
        case .dictionary:
            let dictionaryContainer = try container.nestedContainer(keyedBy: DictionaryKeys.self, forKey: .dictionary)
            self = .dictionary(
                key: try dictionaryContainer.decode(PrimitiveType.self, forKey: .key),
                value: try dictionaryContainer.decode(TypeContainer.self, forKey: .value)
            )
        case .enum:
            let enumContainer = try container.nestedContainer(keyedBy: EnumKeys.self, forKey: .enum)
            let name = try enumContainer.decode(SchemaName.self, forKey: .name)
            let cases = try enumContainer.decode([String].self, forKey: .cases)
            self = .enum(name: name, cases: cases)
        case .complex:
            let complexContainer = try container.nestedContainer(keyedBy: ComplexKeys.self, forKey: .complex)
            self = .complex(
                name: try complexContainer.decode(SchemaName.self, forKey: .name),
                properties: try complexContainer.decode([TypeProperty].self, forKey: .properties)
            )
        default: fatalError("Failed to decode type container")
        }
    }
}
