import Foundation

/// Builds a valid JSON string with values empty strings, 0 for numbers, empty Data, date of today, and random UUID
/// by means of a `typeInformation` object
struct JSONStringBuilder {
    /// JSONDecoder
    private static let decoder = JSONDecoder()
    
    /// `TypeInformation` of the type that is used as template for JSONString
    private let typeInformation: TypeInformation
    
    /// Retrieves the default initializable type if `typeInformation` is a scalar
    private var defaultInitializableType: DefaultInitializable.Type? {
        switch typeInformation {
        case let .scalar(primitiveType): return primitiveType.swiftType
        default: return nil
        }
    }
    
    /// Initializes an instance from a TypeInformation
    init(_ typeInformation: TypeInformation) {
        self.typeInformation = typeInformation
    }
    
    /// Initializes an instance from Any Type
    init(_ type: Any.Type) throws {
        typeInformation = try .init(type: type)
    }
    
    /// Initializes an instance from Any instance
    init(value: Any) throws {
        typeInformation = try .init(value: value)
    }
    
    /// Dictionaries are encoded either with curly brackes `{ "key" : value }` if the key is String or Int,
    /// or as an array containing keys and values interchangeably e.g. [key, value] for keys of other types
    func requiresCurlyBrackets(_ primitiveType: PrimitiveType) -> Bool {
        [.string, .int].contains(primitiveType)
    }

    /// Returns the right format for keys of the dictionary
    func dictionaryKey(_ primitiveType: PrimitiveType) -> String {
        let jsonString = primitiveType.swiftType.jsonString
        return primitiveType == .int ? jsonString.asString : jsonString
    }
    
    /// Builds and returns a valid JSON string from the `typeInformation`.
    func build() -> String {
        switch typeInformation {
        case let .repeated(element):
            return "[\(JSONStringBuilder(element).build())]"
        case let .dictionary(key, value):
            if requiresCurlyBrackets(key) {
                return "{ \(dictionaryKey(key)) : \(JSONStringBuilder(value).build()) }"
            }
            return "[\(dictionaryKey(key)), \(JSONStringBuilder(value).build())]"
        case let .optional(wrappedValue):
            return "\(JSONStringBuilder(wrappedValue.unwrapped).build())"
        case let .enum(_, cases):
            return cases.first?.name.value.asString ?? "{}"
        case let .object(_, properties):
            let sorted = properties.sorted { $0.name.value < $1.name.value }
            return "{\(sorted.map { "\(String.lineBreak)" + $0.name.value.asString + " : \(JSONStringBuilder($0.type).build())" }.joined(separator: ", "))\(String.lineBreak)}"
        default: return defaultInitializableType?.jsonString ?? "{}"
        }
    }
    
    static func string<C: Codable>(_ type: C.Type) throws -> String {
        try instance(C.self).json
    }
    
    /// Initializes an Instance out of a decodable type.
    static func instance<D: Decodable>(_ type: D.Type) throws -> D {
        try decode(D.self, from: try Self(D.self).build())
    }
    
    /// Initializes an instance out of a `typeInformation` and a specified decodable type
    static func instance<D: Decodable>(_ typeInformation: TypeInformation, _ type: D.Type) throws -> D {
        try decode(D.self, from: Self(typeInformation).build())
    }
    
    /// Decodes type from data
    static func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D {
        try decoder.decode(D.self, from: data)
    }
    
    /// Decodes type from path
    static func decode<D: Decodable>(_ type: D.Type, at path: Path) throws -> D {
        try decoder.decode(D.self, from: try path.read())
    }
    
    /// Decodes type from string content
    static func decode<D: Decodable>(_ type: D.Type, from string: String) throws -> D {
        guard let data = string.data(using: .utf8) else {
            fatalError("String encoding failed")
        }
        return try decoder.decode(D.self, from: data)
    }
}
