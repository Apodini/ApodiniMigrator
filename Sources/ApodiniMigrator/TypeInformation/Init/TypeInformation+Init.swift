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
        var relationshipTypes: Set<ObjectIdentifier> = [ObjectIdentifier(type)]
        return try Self(type, relationshipTypes: &relationshipTypes, skipRelationshipCheck: true)
    }
    
    /// Initializer that handles the logic to create a new TypeInformation instance
    /// The initializers performes several recursive calls depending on the type that is being processed
    /// - Parameters:
    ///     - type: the type for which this instance is being created
    ///     - relationshipTypes: potential Fluent relationship types, that can be encountered starting from the root call of the initializer in `typeInformation(for:) throws`
    ///     - skipRelationshipCheck: a flag with default value `false`. Used to return a `.relationship` type information instance in case that `type` is already contained in `relationshipTypes`
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init(_ type: Any.Type, relationshipTypes: inout Set<ObjectIdentifier>, skipRelationshipCheck: Bool = false) throws {
        if !skipRelationshipCheck && relationshipTypes.contains(type: type) { // encountered a circular reference
            self = .relationship(name: .init(type))
        } else {
            if let primitiveType = PrimitiveType(type) {
                self = .scalar(primitiveType)
            } else {
                let typeInfo = try Runtime.typeInfo(of: type)
                let genericTypes = typeInfo.genericTypes
                let mangledName = MangledName(typeInfo.mangledName)
                
                if mangledName == .repeated, let elementType = genericTypes.first {
                    self = .repeated(element: try .init(elementType, relationshipTypes: &relationshipTypes))
                } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
                    if let keyType = PrimitiveType(keyType) {
                        self = .dictionary(key: keyType, value: try .init(valueType, relationshipTypes: &relationshipTypes))
                    } else {
                        throw TypeInformationError.notSupportedDictionaryKeyType
                    }
                } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
                    self = .optional(wrappedValue: try .init(wrappedValueType, relationshipTypes: &relationshipTypes))
                } else if typeInfo.kind == .enum {
                    self = .enum(name: typeInfo.typeName, cases: typeInfo.cases.map { EnumCase($0.name) })
                } else if [.struct, .class].contains(typeInfo.kind) {
                    let propertiesTypeInfos: [TypeInfoProperty] = try typeInfo.properties
                        .map { .init(typeInfo: try Runtime.typeInfo(of: $0.type), propertyName: $0.name) }
                    let hasRelationshipFluentProperties = propertiesTypeInfos
                        .contains(where: { $0.fluentPropertyType?.isRelationshipProperty == true })
                    
                    // if the type has relationship properties, appending it already to relationshipTypes, so that potential occurrencies of it,
                    // can be initialized as .relationship
                    if hasRelationshipFluentProperties {
                        relationshipTypes += typeInfo.type
                    }
                    
                    let properties: [TypeProperty] = try propertiesTypeInfos
                        .compactMap {
                            do {
                                var name = $0.propertyName
                                /// if the property is a fluentPropertyType, the initialization is passed to `init(for:with:relationshipTypes:) throws`
                                if let fluentPropertyType = $0.fluentPropertyType {
                                    name = String(name.dropFirst())
                                    let genericTypes = $0.typeInfo.genericTypes
                                    let propertyTypeInformation: TypeInformation = try .init(
                                        for: fluentPropertyType,
                                        with: genericTypes,
                                        relationshipTypes: &relationshipTypes
                                    )
                                    return .init(name: name, type: propertyTypeInformation)
                                }
 
                                return .init(name: name, type: try .init($0.type, relationshipTypes: &relationshipTypes))
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
    
    /// This initializer serves the purpose to retrieve the type of the `wrappedValue` property of Fluent property wrappers.
    /// The raw type is always in the second position of the generic types (exept of the `TimestampProperty`), however the cardinalty might be different.
    /// This initializer ensures the initialization of an instance with the right cardinality for each Fluent property type
    /// - Parameters:
    ///     - fluentPropertyType: the type of the fluent proeperty
    ///     - genericTypes: generic types associated with the property wrapper of Fluent
    ///     - relationshipTypes: accumulated `relationshipTypes` from the root call. Not changed inside this initializer though, only passed to upcoming calls
    init(for fluentPropertyType: FluentPropertyType, with genericTypes: [Any.Type], relationshipTypes: inout Set<ObjectIdentifier>) throws {
        guard genericTypes.count >= 2 else {
            throw TypeInformationError.malformedFluentProperty(message: "Failed to construct TypeInformation of fluent property: \(fluentPropertyType.rawValue.upperFirst)")
        }

        let nestedPropertyType = genericTypes[1]
        switch fluentPropertyType {
        // wrapped value is always Optional<Date>
        case .timestampProperty: self = .optional(wrappedValue: .scalar(.date))
        // wrapped value is always an array of nestedPropertyType
        case .childrenProperty, .siblingsProperty: self = .repeated(element: try .init(nestedPropertyType, relationshipTypes: &relationshipTypes))
        case .enumProperty, .fieldProperty, .parentProperty: self = try .init(nestedPropertyType, relationshipTypes: &relationshipTypes)
        default: self = .optional(wrappedValue: try .init(nestedPropertyType, relationshipTypes: &relationshipTypes))
        }
    }
}

// MARK: - FluentPropertyType
extension FluentPropertyType {
    /// Indicates whether the type of the property might introduce some kind of relationship
    var isRelationshipProperty: Bool {
        [.childrenProperty, .optionalChildProperty, .optionalParentProperty, .parentProperty, .siblingsProperty].contains(self)
    }
}

// MARK: - TypeInfo
fileprivate extension TypeInfo {
    /// TypeName of the type of the `Runtime.TypeInfo`
    var typeName: TypeName {
        .init(type)
    }
}

/// A helper struct to initialize properties of a `TypeInfo` instance
private struct TypeInfoProperty {
    /// typeInfo of the property
    let typeInfo: TypeInfo
    /// property name
    let propertyName: String
    
    /// type of the property
    var type: Any.Type {
        typeInfo.type
    }
    
    /// fluentPropertyType if the mangledName of `typeInfo` corresponds to a Fluent property wrapper type
    var fluentPropertyType: FluentPropertyType? {
        if case let .fluentPropertyType(fluentPropertyType) = MangledName(typeInfo.mangledName) {
            return fluentPropertyType
        }
        return nil
    }
}

// MARK: - Set
extension Set where Element == ObjectIdentifier {
    func contains(type: Any.Type) -> Bool {
        contains(ObjectIdentifier(type))
    }
    
    static func += (lhs: inout Self, rhs: Any.Type) {
        lhs.insert(ObjectIdentifier(rhs))
    }
}
