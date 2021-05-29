import Foundation
@_implementationOnly import Runtime

public extension TypeInformation {
    enum TypeInformationError: Error {
        case notSupportedDictionaryKeyType
        case initFailure(message: String)
        case malformedFluentProperty(message: String)
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

fileprivate extension TypeInformation {
    static func typeInformation(for type: Any.Type) throws -> TypeInformation {
        var processed: Set<ObjectIdentifier> = []
        return try Self(type, processed: &processed)
    }
    
    /// Initializer that handles the logic to create a new TypeInformation instance
    init(_ type: Any.Type, processed: inout Set<ObjectIdentifier>) throws {
        if processed.contains(ObjectIdentifier(type)) { // encountered a circular reference
            self = .relationship(name: .init(type))
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
                
                /// if the type is a fluent property, the initalization is passed to the initializer that retrieves the type out of the property wrapper
                } else if case let .fluentPropertyType(fluentPropertyType) = mangledName {
                    self = try .init(for: fluentPropertyType, genericTypes: genericTypes, processed: &processed)
                } else if [.struct, .class].contains(typeInfo.kind) {
                    // Inserting type as processed now even though not actually processed yet, so that the potential occurrencies of this type,
                    // in its nested types get initialised as a `.relationship` with the name of the type
                    processed.insert(ObjectIdentifier(typeInfo.type))
                    let properties: [TypeProperty] = try typeInfo.properties
                        .compactMap {
                            do {
                                var name = $0.name
                                let propertyTypeInfo = try Runtime.typeInfo(of: $0.type)
                                
                                if MangledName(propertyTypeInfo.mangledName).isFluentPropertyType, name.hasPrefix("_") {
                                    name = String(name.dropFirst())
                                }
                                return .init(name: .init(name), type: try .init($0.type, processed: &processed))
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
    
    init(for fluentPropertyType: FluentPropertyType, genericTypes: [Any.Type], processed: inout Set<ObjectIdentifier>) throws {
        guard genericTypes.count >= 2 else {
            throw TypeInformationError.malformedFluentProperty(message:"Failed to construct TypeInformation of fluent property: \(fluentPropertyType.rawValue.upperFirst)")
        }
        
        let nestedPropertyType = genericTypes[1]
        switch fluentPropertyType {
        case .timestampProperty: // wrapped value is always Optional<Date>
            self = .optional(wrappedValue: .scalar(.date))
        case .childrenProperty: // wrapped value is always an array of nestedPropertyType
            self = .repeated(element: try .init(nestedPropertyType, processed: &processed))
        case .enumProperty, .fieldProperty, .parentProperty, .siblingsProperty:
            self = try .init(nestedPropertyType, processed: &processed)
        default:
            self = .optional(wrappedValue: try .init(nestedPropertyType, processed: &processed))
        }
    }
}

fileprivate extension TypeInfo {
    var typeName: TypeName {
        .init(type)
    }
}
