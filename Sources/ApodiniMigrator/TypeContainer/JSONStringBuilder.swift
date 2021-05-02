import Foundation

struct JSONStringBuilder {
    private let typeContainer: TypeContainer
    
    private var defaultInitializableType: DefaultInitializable.Type? {
        switch typeContainer {
        case let .primitive(primitiveType): return primitiveType.swiftType
        default: return nil
        }
    }
    
    init(_ typeContainer: TypeContainer) {
        self.typeContainer = typeContainer
    }
    
    init(_ type: Any.Type) throws {
        typeContainer = try .init(type: type)
    }
    
    init(value: Any) throws {
        typeContainer = try .init(value: value)
    }
    
    func requiresCurlyBrackets(_ primitiveType: PrimitiveType) -> Bool {
        [.string, .int].contains(primitiveType)
    }
    
    func jsonString(_ primitiveType: PrimitiveType) -> String {
        primitiveType.swiftType.jsonString
    }
    
    func build() -> String {
        switch typeContainer {
        case .array(element: let element):
            return "[\(JSONStringBuilder(element).build())]"
        case .dictionary(key: let key, value: let value):
            if requiresCurlyBrackets(key) { return "{ \(jsonString(key)) : \(JSONStringBuilder(value).build()) }" }
            return "[\(jsonString(key)), \(JSONStringBuilder(value).build())]"
        case .optional(wrappedValue: let wrappedValue):
            return "\(JSONStringBuilder(wrappedValue).build())"
        case .enum(name: _, cases: let cases):
            return cases.first?.asString ?? "{}"
        case .complex(name: _, properties: let properties):
            let sorted = properties.sorted { $0.name.value < $1.name.value }
            return "{\(sorted.map { $0.name.value.asString + ": \(JSONStringBuilder($0.type).build())" }.joined(separator: ", "))}"
        default: return defaultInitializableType?.jsonString ?? "{}"
        }
    }
    
    
    static func instance<C: Codable>(_ type: C.Type) throws -> C {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iSO8601DateFormatter)
        let data = try Self(C.self).build().data(using: .utf8) ?? Data()
        return try decoder.decode(C.self, from: data)
    }
}
