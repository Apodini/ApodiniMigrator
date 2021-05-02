import Foundation
@_implementationOnly import Runtime

extension TypeContainer {
    enum TypeContainerError: Error {
        case notSupportedDictionaryKeyType
    }
    
    /// Initializes a type container from Any instance
    init(value: Any) throws {
        self = try .init(type: type(of: value))
    }
    
    /// Initializes a type container from Any type
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
                self = .enum(name: typeInfo.schemaName, cases: typeInfo.cases.map { $0.name })
            } else {
                let properties: [TypeProperty] = try typeInfo.properties.map { .init(name: .init($0.name), type: try .init(type: $0.type)) }
                self = .complex(name: typeInfo.schemaName, properties: properties)
            }
        }
    }
    
    /// A convinience static function that returns a type container using Apodini's ReflectionInfo implementation
    static func withReflectionInfo(_ type: Any.Type) throws -> TypeContainer {
        if let primitiveType = PrimitiveType(type) {
            return .primitive(primitiveType)
        } else {
            let node = try ReflectionInfo.node(type).handleCardinalities()
            let typeInfo = node.value.typeInfo
            
            if node.isEnum {
                return .enum(name: typeInfo.schemaName, cases: typeInfo.cases.map { $0.name })
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
}
