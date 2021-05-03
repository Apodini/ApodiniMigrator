import Foundation
@_implementationOnly import Runtime

extension TypeContainer {
    enum TypeContainerError: Error {
        case notSupportedDictionaryKeyType
    }
    
    /// Initializes a type container from Any instance
    init(value: Any) throws {
        self = try .init(type: Swift.type(of: value))
    }
    
    /// Initializes a type container from Any type
    init(type: Any.Type) throws {
        if let primitiveType = PrimitiveType(type) {
            self = .primitive(primitiveType)
        } else {
            let typeInfo = try Runtime.typeInfo(of: type)
            let genericTypes = typeInfo.genericTypes
            let mangledName = typeInfo._mangledName
            
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
                self = .enum(name: typeInfo.schemaName, cases: typeInfo.cases.map { EnumCase($0.name) })
            } else {
                let properties: [TypeProperty] = try typeInfo.properties.map { .init(name: .init($0.name), type: try .init(type: $0.type)) }
                self = .complex(name: typeInfo.schemaName, properties: properties)
            }
        }
    }
}
