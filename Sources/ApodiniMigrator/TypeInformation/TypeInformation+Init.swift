import Foundation
@_implementationOnly import Runtime

extension TypeInformation {
    enum TypeInformationError: Error {
        case notSupportedDictionaryKeyType
        case initFailure(message: String)
    }
    
    /// Initializes a type container from Any instance
    init(value: Any) throws {
        self = try .init(type: Swift.type(of: value))
    }
    
    /// Initializes a type container from Any type
    init(type: Any.Type) throws {
        if let primitiveType = PrimitiveType(type) {
            self = .scalar(primitiveType)
        } else {
            let typeInfo = try Runtime.typeInfo(of: type)
            let genericTypes = typeInfo.genericTypes
            let mangledName = MangledName(typeInfo.mangledName)
            
            if mangledName == .repeated, let elementType = genericTypes.first {
                self = .repeated(element: try .init(type: elementType))
            } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
                if let keyType = PrimitiveType(keyType) {
                    self = .dictionary(key: keyType, value: try .init(type: valueType))
                } else {
                    throw TypeInformationError.notSupportedDictionaryKeyType
                }
            } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
                self = .optional(wrappedValue: try .init(type: wrappedValueType))
            } else if typeInfo.kind == .enum {
                self = .enum(name: typeInfo.typeName, cases: typeInfo.cases.map { EnumCase($0.name) })
            } else if [.struct, .class].contains(typeInfo.kind) {
                let properties: [TypeProperty] = try typeInfo.properties
                    .compactMap {
                        do {
                            return .init(name: .init($0.name), type: try .init(type: $0.type))
                        } catch {
                            let errorDescription = String(describing: error)
                            let ignoreError = [
                                "\(Runtime.Kind.opaque)",
                                "\(Runtime.Kind.function)"
                            ].contains(where: { errorDescription.contains($0) })
                            
                            if ignoreError {
                                return nil
                            }
                            
                            throw TypeInformationError.initFailure(message: errorDescription)
                        }
                    }
                self = .object(name: typeInfo.typeName, properties: properties)
            } else {
                throw TypeInformationError.initFailure(message: "TypeInformation construction of \(typeInfo.kind) is not supported")
            }
        }
    }
}

extension TypeInfo {
    var typeName: TypeName {
        .init(type)
    }
}
