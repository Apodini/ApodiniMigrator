import Foundation

struct JSONStringBuilder {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iSO8601DateFormatter)
        return decoder
    }()
    
    private let typeDescriptor: TypeDescriptor
    
    private var defaultInitializableType: DefaultInitializable.Type? {
        switch typeDescriptor {
        case let .scalar(primitiveType): return primitiveType.swiftType
        default: return nil
        }
    }
    
    init(_ typeDescriptor: TypeDescriptor) {
        self.typeDescriptor = typeDescriptor
    }
    
    init(_ type: Any.Type) throws {
        typeDescriptor = try .init(type: type)
    }
    
    init(value: Any) throws {
        typeDescriptor = try .init(value: value)
    }
    
    func requiresCurlyBrackets(_ primitiveType: PrimitiveType) -> Bool {
        [.string, .int].contains(primitiveType)
    }
    
    func jsonString(_ primitiveType: PrimitiveType) -> String {
        primitiveType.swiftType.jsonString
    }
    
    func build() -> String {
        switch typeDescriptor {
        case let .array(element):
            return "[\(JSONStringBuilder(element).build())]"
        case let .dictionary(key, value):
            if requiresCurlyBrackets(key) {
                return "{ \(jsonString(key)) : \(JSONStringBuilder(value).build()) }"
            }
            return "[\(jsonString(key)), \(JSONStringBuilder(value).build())]"
        case let .optional(wrappedValue):
            return "\(JSONStringBuilder(wrappedValue).build())"
        case let .enum(_, cases):
            return cases.first?.name.value.asString ?? "{}"
        case let .object(_, properties):
            let sorted = properties.sorted { $0.name.value < $1.name.value }
            return "{\(sorted.map { $0.name.value.asString + ": \(JSONStringBuilder($0.type).build())" }.joined(separator: ", "))}"
        default: return defaultInitializableType?.jsonString ?? "{}"
        }
    }
    
    
    static func instance<C: Codable>(_ type: C.Type) throws -> C {
        let data = try Self(C.self).build().data(using: .utf8) ?? Data()
        return try decoder.decode(C.self, from: data)
    }
    
    static func instance<C: Codable>(_ typeDescriptor: TypeDescriptor, _ type: C.Type) throws -> C {
        let data = Self(typeDescriptor).build().data(using: .utf8) ?? Data()
        return try decoder.decode(C.self, from: data)
    }
}
