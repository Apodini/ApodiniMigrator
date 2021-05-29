import Foundation
@_implementationOnly import Runtime

public extension TypeInformation {
    enum TypeInformationError: Error {
        case notSupportedDictionaryKeyType
        case initFailure(message: String)
    }
    
    /// Initializes a type information from Any instance
    init(value: Any) throws {
        self = try .init(type: Swift.type(of: value))
    }
    
    
    /// Initializes a type information from Any type
    init(type: Any.Type) throws {
        self = try .typeInformation(for: type)
    }

}

extension TypeInformation {
    
    private static func typeInformation(for type: Any.Type) throws -> TypeInformation {
        var processed: Set<ObjectIdentifier> = []
        return try TypeInformation(type, processed: &processed)
    }
    
    private init(_ type: Any.Type, processed: inout Set<ObjectIdentifier>) throws {
        if processed.contains(ObjectIdentifier(type)) {
            self = .circularReference(name: .init(type))
        } else {
            if let primitiveType = PrimitiveType(type) {
                self = .scalar(primitiveType)
            } else {
                let typeInfo = try Runtime.typeInfo(of: type)
                let genericTypes = typeInfo.genericTypes
                let mangledName = MangledName(typeInfo.mangledName)
                
                if mangledName == .repeated, let elementType = genericTypes.first {
                    self = .repeated(element: try .init(elementType, processed: &processed))
                } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
                    if let keyType = PrimitiveType(keyType) {
                        self = .dictionary(key: keyType, value: try .init(valueType, processed: &processed))
                    } else {
                        throw TypeInformationError.notSupportedDictionaryKeyType
                    }
                } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
                    self = .optional(wrappedValue: try .init(wrappedValueType, processed: &processed))
                } else if typeInfo.kind == .enum {
                    self = .enum(name: typeInfo.typeName, cases: typeInfo.cases.map { EnumCase($0.name) })
                } else if [.struct, .class].contains(typeInfo.kind) {
                    processed.insert(ObjectIdentifier(typeInfo.type))
                    let properties: [TypeProperty] = try typeInfo.properties
                        .compactMap {
                            do {
                                let propertyType = $0.type
                                let propertyTypeInformation: TypeInformation = processed.contains(ObjectIdentifier(propertyType))
                                    ? .circularReference(name: .init(propertyType))
                                    : try .init($0.type, processed: &processed)
                                return .init(name: .init($0.name), type: propertyTypeInformation)
                            } catch {
                                let errorDescription = String(describing: error)
                                let ignoreError = [
                                    "\(Runtime.Kind.opaque)",
                                    "\(Runtime.Kind.function)",
                                    "\(Runtime.Kind.existential)"
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
}

fileprivate extension TypeInfo {
    var typeName: TypeName {
        .init(type)
    }
}
