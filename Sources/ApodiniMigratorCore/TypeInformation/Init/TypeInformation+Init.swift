//
//  TypeInformation+Init.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - TypeInformation public
public extension TypeInformation {
    /// Errors
    enum TypeInformationError: Error {
        case notSupportedDictionaryKeyType
        case initFailure(message: String)
        case malformedFluentProperty(message: String)
        case enumCaseWithAssociatedValue(message: String)
    }
    
    /// Initializes a type information from Any instance using `RuntimeBuilder`
    init(value: Any) throws {
        self = try .init(type: type(of: value))
    }
    
    /// Initializes a type information instance from any type using `RuntimeBuilder`
    init(type: Any.Type) throws {
        self = try .init(for: type)
    }
}

// MARK: - TypeInformation internal
extension TypeInformation {
    /// Returns a typeInformation instance from `type`, however does not include properties of any object encountered from the root type
    static func withoutProperties(for type: Any.Type) throws -> TypeInformation {
        try .init(for: type, includeObjectProperties: false)
    }
    
    /// Initializes a typeinformation instance from `type`. `includeObjectProperties` flag that indicates whether to include object properties or not
    private init(for type: Any.Type, includeObjectProperties: Bool = true) throws {
        if let type = type as? TypeInformationPrimitiveConstructor.Type {
            self = type.construct()
        } else if let type = type as? TypeInformationComplexConstructor.Type {
            self = try type.construct(with: RuntimeBuilder.self)
        } else {
            let typeInfo = try info(of: type)
        
            if typeInfo.kind == .enum {
                guard typeInfo.numberOfPayloadEnumCases == 0 else {
                    throw TypeInformationError.enumCaseWithAssociatedValue(message: "Construction of enums with associated values is currently not supported")
                }
                self = .enum(name: typeInfo.typeName, cases: typeInfo.cases.map { .case($0.name) })
            } else if [.struct, .class].contains(typeInfo.kind) {
                let properties: [TypeProperty] = !includeObjectProperties ? [] : try typeInfo.properties()
                    .compactMap {
                        do {
                            if let fluentProperty = $0.fluentPropertyType {
                                return .fluentProperty(
                                    $0.name,
                                    type: try .fluentProperty($0),
                                    annotation: fluentProperty.description
                                )
                            }
                            
                            if let wrappedValueType = $0.propertyWrapperWrappedValueType {
                                return .init(
                                    name: $0.name,
                                    type: try .init(for: wrappedValueType),
                                    annotation: "@" + $0.typeInfo.mangledName
                                )
                            }
                            
                            return .property($0.name, type: try .init(for: $0.type))
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
    
    /// Returns the typeinformation instance corresponding to `property`, by considering the type of wrappedValue of property wrapper
    private static func fluentProperty(_ property: RuntimeProperty) throws -> TypeInformation {
        guard let fluentProperty = property.fluentPropertyType, property.genericTypes.count > 1 else {
            throw TypeInformationError.malformedFluentProperty(message: "Failed to construct TypeInformation of property \(property.name) of \(property.ownerType)")
        }
        
        let nestedPropertyType = property.genericTypes[1]
        switch fluentProperty {
        case .timestampProperty: return .optional(wrappedValue: .scalar(.date))
        case .enumProperty, .fieldProperty, .groupProperty:
            return try .init(for: nestedPropertyType)
        case .iDProperty, .optionalEnumProperty, .optionalChildProperty, .optionalFieldProperty:
            return .optional(wrappedValue: try .init(for: nestedPropertyType))
        case .childrenProperty:
            return .repeated(element: try .init(for: nestedPropertyType))
        case .optionalParentProperty, .parentProperty: return try .parentProperty(of: property)
        case .siblingsProperty: return try .siblingsProperty(of: property)
        }
    }
    
    /// Initializes a typeinformation instance corresponding to a `@Parent` fluent property wrapper
    private static func parentProperty(of property: RuntimeProperty) throws -> TypeInformation {
        let nestedPropertyType = property.genericTypes[1] /// safe access, ensured in `fluentProperty(:)`
        let typeInfo = try info(of: nestedPropertyType)
        guard
            let idProperty = typeInfo.properties.firstMatch(on: \.name, with: "_id"),
            let propertyTypeInfo = try? RuntimeProperty(idProperty),
            propertyTypeInfo.isIDProperty,
            propertyTypeInfo.genericTypes.count > 1
        else { throw TypeInformationError.malformedFluentProperty(message: "Could not find the id property of \(nestedPropertyType)") }
        
        let idType = propertyTypeInfo.genericTypes[1]
        
        let customIDObject: TypeInformation = .object(
            name: .init(name: String(describing: nestedPropertyType) + "ID"),
            properties: [.property("id", type: .optional(wrappedValue: try .init(for: idType)))]
        )
        
        return property.fluentPropertyType == .optionalParentProperty
            ? .optional(wrappedValue: customIDObject)
            : customIDObject
    }
    
    /// Initializes a typeinformation instance corresponding to a `@Siblings` fluent property wrapper
    private static func siblingsProperty(of siblingsProperty: RuntimeProperty) throws -> TypeInformation {
        let nestedPropertyType = siblingsProperty.genericTypes[1] /// safe access, ensured in `fluentProperty(:)`
        let typeInfo = try info(of: nestedPropertyType)
        let properties: [TypeProperty] = try typeInfo.properties()
            .compactMap { nestedTypeProperty in
                if nestedTypeProperty.isFluentProperty {
                    if nestedTypeProperty.fluentPropertyType == .siblingsProperty,
                       ObjectIdentifier(siblingsProperty.ownerType) == ObjectIdentifier(nestedTypeProperty.genericTypes[1]) {
                        return nil
                    }
                    
                    let propertyTypeInformation: TypeInformation = try .fluentProperty(nestedTypeProperty)
                    return .init(
                        name: nestedTypeProperty.name,
                        type: propertyTypeInformation,
                        annotation: nestedTypeProperty.fluentPropertyType?.description
                    )
                }
                return .init(
                    name: nestedTypeProperty.name,
                    type: try .init(for: nestedTypeProperty.type),
                    annotation: nestedTypeProperty.fluentPropertyType?.description
                )
            }
        return .repeated(element: .object(name: typeInfo.typeName, properties: properties))
    }
}
