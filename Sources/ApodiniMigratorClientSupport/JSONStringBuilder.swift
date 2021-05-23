import Foundation
import ApodiniMigrator
@_exported import ApodiniMigratorShared

/// Builds a valid JSON string with values empty strings, 0 for numbers, empty Data, date of today, and random UUID
/// by means of a `typeInformation` object
public struct JSONStringBuilder {
   /// `TypeInformation` of the type that is used as template for JSONString
    private let typeInformation: TypeInformation
    /// `JSONEncoder` used to encode the value of the type
    private let encoder: JSONEncoder
    
    /// Initializes `self` with an `ApodiniMigratorCodable` type
    init<C: ApodiniMigratorCodable>(_ type: C.Type) throws {
        self.typeInformation = try TypeInformation(type: C.self)
        self.encoder = C.encoder
    }
    
    init(_ type: Any.Type, encoder: JSONEncoder = .init()) throws {
        self.init(try TypeInformation(type: type), encoder: encoder)
    }
    
    /// Private initializer for `json` string builder of an empty instance
    private init(_ typeInformation: TypeInformation, encoder: JSONEncoder = .init()) {
        self.typeInformation = typeInformation
        self.encoder = encoder
    }
    
    /// Initializes `self` with a `typeInformation` property and an `EncoderConfiguration` object
    init(_ typeInformation: TypeInformation, with configuration: EncoderConfiguration) {
        self.typeInformation = typeInformation
        self.encoder = JSONEncoder().configured(with: configuration)
    }
    
    /// Dictionaries are encoded either with curly brackes `{ "key" : value }` if the key is String or Int,
    /// or as an array containing keys and values interchangeably e.g. [key, value] for keys of other types
    private func requiresCurlyBrackets(_ primitiveType: PrimitiveType) -> Bool {
        [.string, .int].contains(primitiveType)
    }

    /// Returns the right format for keys of the dictionary
    private func dictionaryKey(_ primitiveType: PrimitiveType) -> String {
        let jsonString = primitiveType.swiftType.jsonString
        return primitiveType == .int ? jsonString.asString : jsonString
    }
    
    /// Builds and returns a valid JSON string from the `typeInformation`
    private func build() -> String {
        switch typeInformation {
        case let .scalar(primitiveType):
            return primitiveType.jsonString(with: encoder)
        case let .repeated(element):
            return "[\(Self(element, encoder: encoder).build())]"
        case let .dictionary(key, value):
            if requiresCurlyBrackets(key) {
                return "{ \(dictionaryKey(key)) : \(Self(value, encoder: encoder).build()) }"
            }
            return "[\(dictionaryKey(key)), \(Self(value, encoder: encoder).build())]"
        case let .optional(wrappedValue):
            return "\(Self(wrappedValue.unwrapped, encoder: encoder).build())"
        case let .enum(_, cases):
            return cases.first?.name.value.asString ?? "{}"
        case let .object(_, properties):
            let sorted = properties.sorted(by: \.name)
            return "{\(sorted.map { $0.name.value.asString + " : \(Self($0.type, encoder: encoder).build())" }.joined(separator: ", "))}"
        default: return "{}"
        }
    }
    
    static func jsonString(_ type: Any.Type) throws -> String {
        try Self(type).build()
    }
    
    public static func jsonString(_ typeInformation: TypeInformation) -> String {
        Self(typeInformation).build()
    }
    
    static func string<C: ApodiniMigratorCodable>(_ type: C.Type) throws -> String {
        try instance(C.self).jsonString(with: C.encoder)
    }
    
    /// Initializes an instance out of a `ApodiniMigratorCodable` type.
    static func instance<C: ApodiniMigratorCodable>(_ type: C.Type) throws -> C {
        try decode(C.self, from: try Self(C.self).build())
    }
    
    /// Initializes an `ApodiniMigratorCodable` instance out of a `typeInformation`
    static func instance<C: ApodiniMigratorCodable>(_ typeInformation: TypeInformation, _ type: C.Type) throws -> C {
        try decode(C.self, from: Self(typeInformation, encoder: C.encoder).build())
    }
    
    /// Decodes type from data
    static func decode<D: ApodiniMigratorDecodable>(_ type: D.Type, from data: Data) throws -> D {
        try D.decoder.decode(D.self, from: data)
    }
    
    /// Decodes type from string content
    static func decode<C: ApodiniMigratorDecodable>(_ type: C.Type, from string: String) throws -> C {
        try C.decoder.decode(C.self, from: string.data(using: .utf8) ?? Data())
    }
    
    static func decode<D: ApodiniMigratorDecodable>(_ type: D.Type, at path: Path) throws -> D {
        try D.decoder.decode(D.self, from: try path.read())
    }
}

fileprivate extension Encodable {
    func jsonString(with encoder: JSONEncoder) -> String {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}

fileprivate extension PrimitiveType {
    func jsonString(with encoder: JSONEncoder) -> String {
        swiftType.jsonString(with: encoder)
    }
}

fileprivate extension DefaultInitializable {
    static func jsonString(with encoder: JSONEncoder) -> String {
        defaultValue.jsonString(with: encoder)
    }
}
