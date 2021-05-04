import Foundation

/// Builds a valid JSON string with values empty strings, 0 for numbers, empty Data, date of today, and random UUID
/// by means of a type descriptor object
struct JSONStringBuilder {
    /// JSONDecoder
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iSO8601DateFormatter)
        return decoder
    }()
    
    /// Type descriptor of the type that is used as template for JSONString
    private let typeDescriptor: TypeDescriptor
    
    /// Retrieves the default initializable type if type descriptor is a scalar
    private var defaultInitializableType: DefaultInitializable.Type? {
        switch typeDescriptor {
        case let .scalar(primitiveType): return primitiveType.swiftType
        default: return nil
        }
    }
    
    /// Initializes an instance from a TypeDescriptor
    init(_ typeDescriptor: TypeDescriptor) {
        self.typeDescriptor = typeDescriptor
    }
    
    /// Initializes an instance from Any Type
    init(_ type: Any.Type) throws {
        typeDescriptor = try .init(type: type)
    }
    
    /// Initializes an instance from Any instance
    init(value: Any) throws {
        typeDescriptor = try .init(value: value)
    }
    
    /// Dictionaries are encoded either with curly brackes `{ "key" : value }` if the key is String or Int,
    /// or as an array e.g. [key, value] for keys of other types
    func requiresCurlyBrackets(_ primitiveType: PrimitiveType) -> Bool {
        [.string, .int].contains(primitiveType)
    }

    /// Returns the right format for keys of the dictionary
    func dictionaryKey(_ primitiveType: PrimitiveType) -> String {
        let jsonString = primitiveType.swiftType.jsonString
        return primitiveType == .int ? jsonString.asString : jsonString
    }
    
    /// Builds and returns a valid JSON string from the type descriptor.
    func build() -> String {
        switch typeDescriptor {
        case let .array(element):
            return "[\(JSONStringBuilder(element).build())]"
        case let .dictionary(key, value):
            if requiresCurlyBrackets(key) {
                return "{ \(dictionaryKey(key)) : \(JSONStringBuilder(value).build()) }"
            }
            return "[\(dictionaryKey(key)), \(JSONStringBuilder(value).build())]"
        case let .optional(wrappedValue):
            return "\(JSONStringBuilder(wrappedValue).build())"
        case let .enum(_, cases):
            return cases.first?.name.value.asString ?? "{}"
        case let .object(_, properties):
            let sorted = properties.sorted { $0.name.value < $1.name.value }
            return "{\(sorted.map { $0.name.value.asString + " : \(JSONStringBuilder($0.type).build())" }.joined(separator: ", "))}"
        default: return defaultInitializableType?.jsonString ?? "{}"
        }
    }
    
    /// Initializes an Instance out of a codable type.
    static func instance<C: Codable>(_ type: C.Type) throws -> C {
        let data = try Self(C.self).build().data(using: .utf8) ?? Data()
        return try decoder.decode(C.self, from: data)
    }
    
    /// Initializes an instance out of a type descriptor and a specified codable type
    static func instance<C: Codable>(_ typeDescriptor: TypeDescriptor, _ type: C.Type) throws -> C {
        let data = Self(typeDescriptor).build().data(using: .utf8) ?? Data()
        return try decoder.decode(C.self, from: data)
    }
}
