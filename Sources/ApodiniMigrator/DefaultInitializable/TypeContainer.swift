import Foundation
@_implementationOnly import Runtime

struct TypeProperty: Hashable {
    let name: PropertyName
    let type: TypeContainer
}

extension PrimitiveType {
    var isString: Bool {
        self == .string
    }
    
    var jsonString: String {
        swiftType.jsonString
    }
}

enum TypeContainer: Hashable {
    case primitive(PrimitiveType)
    
    indirect case array(element: TypeContainer)
    indirect case dictionary(key: PrimitiveType, value: TypeContainer)
    indirect case optional(wrappedValue: TypeContainer)
    
    case `enum`(cases: [String])
    case complex(name: SchemaName, properties: [TypeProperty])
    
    var defaultInitializableType: DefaultInitializable.Type? {
        switch self {
        case let .primitive(primitiveType): return primitiveType.swiftType
        default: return nil
        }
    }
    
    var jsonString: String {
        switch self {
        case .array(element: let element):
            return "[\(element.jsonString)]"
        case .dictionary(key: let key, value: let value):
            if key.isString { return "{ \(key.jsonString) : \(value.jsonString) }" }
            return "[\(key.jsonString), \(value.jsonString)]"
        case .optional(wrappedValue: let wrappedValue):
            return "\(wrappedValue.jsonString)"
        case .enum(cases: let cases):
            return cases.first?.asString ?? "{}"
        case .complex(name: _, properties: let properties):
            let sorted = properties.sorted { $0.name.value < $1.name.value }
            return "{\(sorted.map { $0.name.value.asString + ": \($0.type.jsonString)" }.joined(separator: ", "))}"
        default: return defaultInitializableType?.jsonString ?? "{}"
        }
    }
    
    init(type: Any.Type) throws {
        if let primitiveType = PrimitiveType(type) {
            self = .primitive(primitiveType)
        } else {
            let typeInfo = try Runtime.typeInfo(of: type)
            let genericTypes = typeInfo.genericTypes
            let mangledName = MangledName(type)
            
            if mangledName == .array, let elementType = genericTypes.first {
                self = .array(element: try .init(type: elementType))
            } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
                if let keyType = PrimitiveType(keyType) {
                    self = .dictionary(key: keyType, value: try .init(type: valueType))
                } else {
                    throw TypeContainerError.notSupportedDictionaryKeyType
                }
            } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
                self = .optional(wrappedValue: try .init(type: wrappedValueType))
            } else if typeInfo.kind == .enum {
                self = .enum(cases: typeInfo.cases.map { $0.name })
            } else { self = .complex(name: typeInfo.schemaName, properties: try typeInfo.typeProperties()) }
        }
    }
    
    static func withReflectionInfo(_ type: Any.Type) throws -> TypeContainer {
        if let primitiveType = PrimitiveType(type) {
            return .primitive(primitiveType)
        } else {
            let node = try ReflectionInfo.node(type).handleCardinalities()
            let typeInfo = node.value.typeInfo
            
            if node.isEnum {
                return .enum(cases: typeInfo.cases.map { $0.name })
            }
            
            switch node.value.cardinality {
            case .zeroToOne:
                return .optional(wrappedValue: try .withReflectionInfo(typeInfo.type))
            case .exactlyOne:
                let typeProperties = node.children.compactMap { node -> TypeProperty? in
                    do {
                        let typeInfo = node.value.typeInfo
                        let propertyName = node.value.propertyInfo?.name ?? typeInfo.name
                        return .init(name: .init(propertyName), type: try .withReflectionInfo(typeInfo.type))
                    } catch { return nil }
                }
                return .complex(name: typeInfo.schemaName, properties: typeProperties)
            case let .zeroToMany(collectionContext):
                switch collectionContext {
                
                case .array:
                    return .array(element: try .withReflectionInfo(typeInfo.type))
                    
                case let .dictionary(key: key, value: value):
                    guard let primitiveKey = PrimitiveType(key.typeInfo.type) else {
                        throw TypeContainerError.notSupportedDictionaryKeyType
                    }
                    return .dictionary(key: primitiveKey, value: try .withReflectionInfo(value.typeInfo.type))
                }
            }
        }
    }
    
    
    
    init(value: Any) throws {
        self = try .init(type: type(of: value))
    }
    
    enum TypeContainerError: Error {
        case notSupportedDictionaryKeyType
    }
    
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
        case let (.enum(lhsCases), .enum(rhsCases)):
            return lhsCases.equalsIgnoringOrder(to: rhsCases)
        case let (.complex(lhsName, lhsProperties), .complex(rhsName, rhsProperties)):
            return lhsName == rhsName && lhsProperties.equalsIgnoringOrder(to: rhsProperties)
        default: return false
        }
    }
}

extension TypeInfo {
    func typeProperties() throws -> [TypeProperty] {
        return try properties.map { .init(name: .init($0.name), type: try .init(type: $0.type)) }
    }
}
