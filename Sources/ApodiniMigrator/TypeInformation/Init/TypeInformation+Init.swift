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
    
    
    /// Initializer that handles the logic to create a new TypeInformation instance
    /// The initializers performes several recursive calls depending on the root type that is being processed
    /// - Parameters:
    ///     - type: the type for which this instance is being created
    init(type: Any.Type) throws { // swiftlint:disable:next cyclomatic_complexity function_body_length
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
                let propertiesTypeInfos: [TypeInfoProperty] = try typeInfo.properties
                    .map { .init(typeInfo: try Runtime.typeInfo(of: $0.type), propertyName: $0.name) }
                let properties: [TypeProperty] = try propertiesTypeInfos
                    .compactMap {
                        do {
                            let name = $0.propertyName
                            
                            /// if the property is a non-relationship fluentPropertyType, the initialization is passed to `init(for:with:) throws`,
                            /// which initializes the type information of the property
                            if let fluentPropertyType = $0.fluentPropertyType {
                                return !fluentPropertyType.isRelationshipProperty
                                    ? .init(name: String(name.dropFirst()), type: try Self(for: fluentPropertyType, with: $0.typeInfo.genericTypes))
                                    : nil
                            }
                            
                            /// TODO avoid circular references, currently running into a non-ending recursive loop
                            return .init(name: name, type: try .init(type: $0.type))
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

fileprivate extension TypeInformation {
    /// This initializer serves the purpose to retrieve the type of the `wrappedValue` property of Fluent property wrappers.
    /// The raw type is always in the second position of the generic types (except of the `TimestampProperty`), however the cardinalty might be different.
    /// This initializer ensures the initialization of an instance with the right cardinality for Fluent properties that are not of any of relationship types
    /// - Parameters:
    ///     - fluentPropertyType: the type of the fluent proeperty
    ///     - genericTypes: generic types associated with the property wrapper of Fluent
    init(for fluentPropertyType: FluentPropertyType, with genericTypes: [Any.Type]) throws {
        let propertyMangledName = fluentPropertyType.rawValue.upperFirst
        guard genericTypes.count >= 2 else {
            throw TypeInformationError.malformedFluentProperty(message: "Failed to construct TypeInformation of fluent property: \(propertyMangledName)")
        }
        
        let nestedPropertyType = genericTypes[1]
        switch fluentPropertyType {
        case .enumProperty, .fieldProperty: self = try .init(type: nestedPropertyType)
        case .optionalEnumProperty, .optionalFieldProperty, .iDProperty: self = .optional(wrappedValue: try .init(type: nestedPropertyType))
        case .timestampProperty: self = .optional(wrappedValue: .scalar(.date))
        default: throw TypeInformationError.initFailure(message: "Attempted to initialize a `TypeInformation` instance for a relationship Fluent Property: \(propertyMangledName)")
        }
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
