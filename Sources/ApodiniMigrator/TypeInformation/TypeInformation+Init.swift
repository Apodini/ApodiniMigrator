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
        try Self(type, rootTypes: [ObjectIdentifier(type)], isRoot: true)
    }
    
    /// Initializer that handles the logic to create a new TypeInformation instance
    init(_ type: Any.Type, rootTypes: [ObjectIdentifier], isRoot: Bool = false) throws {
        if !isRoot && rootTypes.contains(type: type) { // encountered a circular reference
            self = .relationship(name: .init(type))
        } else {
            if let primitiveType = PrimitiveType(type) {
                self = .scalar(primitiveType)
            } else {
                let typeInfo = try Runtime.typeInfo(of: type)
                let genericTypes = typeInfo.genericTypes
                let mangledName = MangledName(typeInfo.mangledName)
                
                if mangledName == .repeated, let elementType = genericTypes.first {
                    self = .repeated(element: try .init(elementType, rootTypes: rootTypes))
                } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
                    if let keyType = PrimitiveType(keyType) {
                        self = .dictionary(key: keyType, value: try .init(valueType, rootTypes: rootTypes))
                    } else {
                        throw TypeInformationError.notSupportedDictionaryKeyType
                    }
                } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
                    self = .optional(wrappedValue: try .init(wrappedValueType, rootTypes: rootTypes))
                } else if typeInfo.kind == .enum {
                    self = .enum(name: typeInfo.typeName, cases: typeInfo.cases.map { EnumCase($0.name) })
                } else if [.struct, .class].contains(typeInfo.kind) {
                    let properties: [TypeProperty] = try typeInfo.properties
                        .compactMap {
                            do {
                                let name = $0.name
                                let propertyTypeInfo = try Runtime.typeInfo(of: $0.type)
                                let mangledName = MangledName(propertyTypeInfo.mangledName)
                                
                                if case let .fluentPropertyType(fluentPropertyType) = mangledName {
                                    return .init(name: String(name.dropFirst()), type: try .init(for: fluentPropertyType, genericTypes: propertyTypeInfo.genericTypes, rootTypes: rootTypes))
                                }
                                
                                if ObjectIdentifier($0.type) == ObjectIdentifier(typeInfo.type) {
                                    return .init(name: name, type: .relationship(name: typeInfo.typeName))
                                }
                                
                                return .init(name: name, type: try .init($0.type, rootTypes: rootTypes))
                            } catch {
                                let errorDescription = String(describing: error)
                                let ignoreError = [
                                    "\(Runtime.Kind.opaque)",
                                    "\(Runtime.Kind.function)",
                                    "\(Runtime.Kind.existential)",
                                    "\(Runtime.Kind.metatype)"
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
    
    init(for fluentPropertyType: FluentPropertyType, genericTypes: [Any.Type], rootTypes: [ObjectIdentifier]) throws {
        guard genericTypes.count >= 2 else {
            throw TypeInformationError.malformedFluentProperty(message: "Failed to construct TypeInformation of fluent property: \(fluentPropertyType.rawValue.upperFirst)")
        }

        let nestedPropertyType = genericTypes[1]
        switch fluentPropertyType {
        case .timestampProperty: // wrapped value is always Optional<Date>
            self = .optional(wrappedValue: .scalar(.date))
        case .childrenProperty, .siblingsProperty: // wrapped value is always an array of nestedPropertyType
            self = .repeated(element: try .init(nestedPropertyType, rootTypes: rootTypes))
        case .enumProperty, .fieldProperty, .parentProperty:
            self = try .init(nestedPropertyType, rootTypes: rootTypes)
        default:
            self = .optional(wrappedValue: try .init(nestedPropertyType, rootTypes: rootTypes))
        }
    }
    
//    init(for fluentPropertyType: FluentPropertyType, genericTypes: [Any.Type], rootTypes: [ObjectIdentifier], isRoot: Bool = false) throws {
//        guard genericTypes.count >= 2 else {
//            throw TypeInformationError.malformedFluentProperty(message: "Failed to construct TypeInformation of fluent property: \(fluentPropertyType.rawValue.upperFirst)")
//        }
//
//        let nestedPropertyType = genericTypes[1]
//        switch fluentPropertyType {
//        case .enumProperty:
//            self = try .init(nestedPropertyType, rootTypes: rootTypes)
//        case .optionalEnumProperty:
//            self = .optional(wrappedValue: try .init(nestedPropertyType, rootTypes: rootTypes))
//        case .childrenProperty:
//            self = .repeated(element: try .init(nestedPropertyType, rootTypes: rootTypes + nestedPropertyType, isRoot: isRoot))
//        case .fieldProperty:
//            self = try .init(nestedPropertyType, rootTypes: rootTypes)
//        case .iDProperty:
//            self = .optional(wrappedValue: try .init(nestedPropertyType, rootTypes: rootTypes))
//        case .optionalChildProperty:
//            self = .optional(wrappedValue: try .init(nestedPropertyType, rootTypes:  rootTypes + nestedPropertyType, isRoot: isRoot))
//        case .optionalFieldProperty:
//            self = .optional(wrappedValue: try .init(nestedPropertyType, rootTypes: rootTypes))
//        case .optionalParentProperty:
//            self = .optional(wrappedValue: try .init(nestedPropertyType, rootTypes:  rootTypes + nestedPropertyType, isRoot: isRoot))
//        case .parentProperty:
//            self = try .init(nestedPropertyType, rootTypes: rootTypes + nestedPropertyType, isRoot: isRoot)
//        case .siblingsProperty:
//            self = .repeated(element: try .init(nestedPropertyType, rootTypes:  rootTypes + nestedPropertyType, isRoot: isRoot))
//        case .timestampProperty:
//            self = .optional(wrappedValue: .scalar(.date))
//        }
//    }
}

extension FluentPropertyType {
    func requiresUpdate() -> Bool {
        [.childrenProperty, .optionalChildProperty, .optionalParentProperty, .parentProperty, .siblingsProperty].contains(self)
    }
}

fileprivate extension TypeInfo {
    var typeName: TypeName {
        .init(type)
    }
}

extension Array where Element == ObjectIdentifier {
    func contains(type: Any.Type) -> Bool {
        contains(ObjectIdentifier(type))
    }
    
    static func + (lhs: Self, rhs: Any.Type) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(ObjectIdentifier(rhs))
        return mutableLhs.unique()
    }
}
