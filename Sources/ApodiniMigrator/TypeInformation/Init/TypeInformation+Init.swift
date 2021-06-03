import Foundation

public extension TypeInformation {
    enum TypeInformationError: Error {
        case notSupportedDictionaryKeyType
        case initFailure(message: String)
        case malformedFluentProperty(message: String)
        case enumCaseWithAssociatedValue(message: String)
    }
    
    /// Initializes a type information from Any instance
    init(value: Any) throws {
        self = try .init(type: type(of: value))
    }
    
    init(type: Any.Type) throws {
        self = try .typeInformation(from: type)
    }
}

extension TypeInformation {
    private static func typeInformation(from type: Any.Type) throws -> TypeInformation {
        var storage = Storage()
        return try .init(for: type, with: &storage)
    }
    
    private init(for type: Any.Type, with storage: inout Storage) throws {
        if let primitiveType = PrimitiveType(type) {
            self = .scalar(primitiveType)
        } else {
            let typeInfo = try info(of: type)
            let genericTypes = typeInfo.genericTypes
            let mangledName = MangledName(typeInfo.mangledName)
            
            if mangledName == .repeated, let elementType = genericTypes.first {
                self = .repeated(element: try .init(for: elementType, with: &storage))
            } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
                if let keyType = PrimitiveType(keyType) {
                    self = .dictionary(key: keyType, value: try .init(for: valueType, with: &storage))
                } else {
                    throw TypeInformationError.notSupportedDictionaryKeyType
                }
            } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
                self = .optional(wrappedValue: try .init(for: wrappedValueType, with: &storage))
            } else if typeInfo.kind == .enum {
                guard typeInfo.numberOfPayloadEnumCases == 0 else {
                    throw TypeInformationError.enumCaseWithAssociatedValue(message: "Construction of enums with associated values is currently not supported")
                }
                self = .enum(name: typeInfo.typeName, cases: typeInfo.cases.map { .case($0.name) })
            } else if [.struct, .class].contains(typeInfo.kind) {
                let properties: [TypeProperty] = try typeInfo.properties()
                    .compactMap {
                        do {
                            if let fluentProperty = $0.fluentPropertyType {
                                return .fluentProperty(
                                    $0.name,
                                    type: try .fluentProperty($0, with: &storage),
                                    annotation: fluentProperty
                                )
                            }
                            
                            return .property($0.name, type: try .init(for: $0.type, with: &storage))
                        } catch {
                            
                            if knownRuntimeError(error) {
                                return nil
                            }
                            
                            throw TypeInformationError.initFailure(message: error.localizedDescription)
                        }
                    }
                self = .object(name: typeInfo.typeName, properties: properties)
            } else {
                throw TypeInformationError.initFailure(message: "TypeInformation construction of \(typeInfo.kind) is not supported")
            }
        }
    }
    
    private static func fluentProperty(
        _ property: RuntimeProperty,
        with storage: inout Storage
    ) throws -> TypeInformation {
        guard let fluentProperty = property.fluentPropertyType, property.genericTypes.count >= 2 else {
            throw TypeInformationError.malformedFluentProperty(message: "Failed to construct TypeInformation of property \(property.name) of \(property.ownerType)")
        }
        
        let nestedPropertyType = property.genericTypes[1]
        switch fluentProperty {
        case .enumProperty, .fieldProperty, .groupProperty:
            return try .init(for: nestedPropertyType, with: &storage)
        case .optionalEnumProperty:
            return .optional(wrappedValue: try .init(for: nestedPropertyType, with: &storage))
        case .childrenProperty:
            return .repeated(element: try .init(for: nestedPropertyType, with: &storage))
        case .iDProperty:
            storage.add(property)
            return .optional(wrappedValue: try .init(for: nestedPropertyType, with: &storage))
        case .optionalChildProperty, .optionalFieldProperty:
            return .optional(wrappedValue: try .init(for: nestedPropertyType, with: &storage))
        case .optionalParentProperty, .parentProperty: return try .parentProperty(of: property, with: &storage)
        case .siblingsProperty: return try .siblingsProperty(of: property, with: &storage)
        case .timestampProperty: return .optional(wrappedValue: .scalar(.date))
        }
    }
    
    private static func parentProperty(of property: RuntimeProperty, with storage: inout Storage) throws -> TypeInformation {
        let nestedPropertyType = property.genericTypes[1]
        let idType: Any.Type
        if let stored = storage.idType(of: nestedPropertyType) {
            idType = stored
        } else {
            let typeInfo = try info(of: nestedPropertyType)
            guard
                let idProperty = typeInfo.properties.firstMatch(on: \.name, with: "_id"),
                let propertyTypeInfo = try? RuntimeProperty(idProperty),
                propertyTypeInfo.isIDProperty,
                propertyTypeInfo.genericTypes.count > 1
            else { fatalError("Could not find the id property of \(nestedPropertyType)") }
            idType = propertyTypeInfo.genericTypes[1]
        }
        
        let customIDObject: TypeInformation = .object(
            name: .init(name: String(describing: nestedPropertyType) + "ID"),
            properties: [.init(name: "id", type: .optional(wrappedValue: try .init(for: idType, with: &storage)))]
        )
        
        return property.fluentPropertyType == .optionalParentProperty
            ? .optional(wrappedValue: customIDObject)
            : customIDObject
    }
    
    private static func siblingsProperty(
        of siblingsProperty: RuntimeProperty,
        with storage: inout Storage
    ) throws -> TypeInformation {
        let nestedPropertyType = siblingsProperty.genericTypes[1]
        let typeInfo = try info(of: nestedPropertyType)
        let properties: [TypeProperty] = try typeInfo.properties()
            .compactMap { nestedTypeProperty in
                if nestedTypeProperty.isFluentProperty {
                    if nestedTypeProperty.fluentPropertyType == .siblingsProperty,
                       ObjectIdentifier(siblingsProperty.ownerType) == ObjectIdentifier(nestedTypeProperty.genericTypes[1]) {
                        return nil
                    }
                    
                    let propertyTypeInformation: TypeInformation = try .fluentProperty(nestedTypeProperty, with: &storage)
                    return .init(name: nestedTypeProperty.name, type: propertyTypeInformation)
                }
                return .init(name: nestedTypeProperty.name, type: try .init(for: nestedTypeProperty.type, with: &storage))
            }
        return .repeated(element: .object(name: typeInfo.typeName, properties: properties))
    }
}
