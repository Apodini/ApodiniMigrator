//
//  TypeInformation+Convenience.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public extension TypeInformation {
    /// A simplified enum of the `typeInformation`
    enum RootType: String, CustomStringConvertible {
        case scalar
        case repeated
        case dictionary
        case optional
        case `enum`
        case object
        case reference
        
        public var description: String { rawValue.upperFirst }
    }
    
    /// The root type of this `typeInformation`
    var rootType: RootType {
        switch self {
        case .scalar: return .scalar
        case .repeated: return .repeated
        case .dictionary: return .dictionary
        case .optional: return .optional
        case .enum: return .enum
        case .object: return .object
        case .reference: return .reference
        }
    }
    
    /// Indicates whether the root type is a scalar (primitive type)
    var isScalar: Bool {
        rootType == .scalar
    }
    
    /// Indicates whether the root type is a repeated type
    var isRepeated: Bool {
        rootType == .repeated
    }
    
    /// Indicates whether the root type is a dictionary
    var isDictionary: Bool {
        rootType == .dictionary
    }
    
    /// Indicates whether the root type is an optional
    var isOptional: Bool {
        rootType == .optional
    }
    
    /// Indicates whether the root type is an enum
    var isEnum: Bool {
        rootType == .enum
    }
    
    /// Indicates whether the root type is an object
    var isObject: Bool {
        rootType == .object
    }
    
    /// Indicates whether the root type is an enum or an object
    var isEnumOrObject: Bool {
        isEnum || isObject
    }
    
    /// Indicates whether the root type is a reference
    var isReference: Bool {
        rootType == .reference
    }
    
    /// If the root type is enum, returns `self`, otherwise the nested types are searched recursively
    var enumType: TypeInformation? {
        switch self {
        case let .repeated(element): return element.enumType
        case let .dictionary(_, value): return value.enumType
        case let .optional(wrappedValue): return wrappedValue.unwrapped.enumType
        case .enum: return self
        default: return nil
        }
    }
    
    /// If the root type is an object, returns `self`, otherwise the nested types are searched recursively
    var objectType: TypeInformation? {
        switch self {
        case let .repeated(element): return element.objectType
        case let .dictionary(_, value): return value.objectType
        case let .optional(wrappedValue): return wrappedValue.objectType
        case .object: return self
        default: return nil
        }
    }

    /// Returns the referenceKey of an nested reference
    var referenceKey: ReferenceKey? {
        if case let .reference(key) = reference {
            return key
        }
        return nil
    }
    
    /// Returns the nested reference if any. References can be stored inside repeated types, dictionaries, optionals, or at top level
    var reference: TypeInformation? {
        switch self {
        case let .repeated(element): return element.reference
        case let .dictionary(_, value): return value.reference
        case let .optional(wrappedValue): return wrappedValue.reference
        case .reference: return self
        default: return nil
        }
    }
    
    /// Indicates whether the nested or top level element is an object
    var elementIsObject: Bool {
        objectType != nil
    }
    
    /// Indicates whether the nested or top level element is an enum
    var elementIsEnum: Bool {
        enumType != nil
    }
    
    /// Indicates whether the nested or top level element is an enum or an object
    var isReferencable: Bool {
        elementIsObject || elementIsEnum
    }
    
    /// The typeName of this `typeInformation`
    /// results in fatal error if requested for a `.reference`
    var typeName: TypeName {
        switch self {
        case let .scalar(primitiveType): return primitiveType.typeName
        case let .repeated(element): return element.unwrapped.typeName
        case let .dictionary(_, value): return value.unwrapped.typeName
        case let .optional(wrappedValue): return wrappedValue.unwrapped.typeName
        case let .enum(name, _, _): return name
        case let .object(name, _): return name
        case let .reference(referenceKey): return .init(name: referenceKey.rawValue)
        }
    }
    
    /// String representation of the type in a `Swift` compliant way
    var typeString: String {
        switch self {
        case let .scalar(primitiveType): return primitiveType.description
        case let .repeated(element): return "[\(element.typeString)]"
        case let .dictionary(key, value): return "[\(key.description): \(value.typeString)]"
        case let .optional(wrappedValue): return wrappedValue.typeString + "?"
        case let .enum(name, _, _): return name.name
        case let .object(name, _): return name.name
        case .reference: return typeName.name
        }
    }
    
    /// Nested type of this type information
    var nestedType: TypeInformation {
        switch self {
        case .scalar, .enum, .object: return self
        case let .repeated(element): return element.nestedType
        case let .dictionary(_, value): return value.nestedType
        case let .optional(wrappedValue): return wrappedValue.unwrapped.nestedType
        default: fatalError("Attempted to request nestedType from a reference")
        }
    }
    
    /// Returns the `objectProperties` by a boolean keypath
    func filterProperties(_ keyPath: KeyPath<TypeInformation, Bool>) -> [TypeProperty] {
        objectProperties.filter { $0.type[keyPath: keyPath] }
    }
    
    /// Indicate whether `self` has the same root type with other `typeInformation`
    func sameType(with typeInformation: TypeInformation) -> Bool {
        rootType == typeInformation.rootType
    }
    
    /// Recursively unwrappes the value of optional type if `self` is `.optional`
    var unwrapped: TypeInformation {
        if case let .optional(wrapped) = self {
            return wrapped.unwrapped
        }
        return self
    }
    
    /// Recursively returns the element of the repeated types (also unwrapped)
    var repeatedElement: TypeInformation? {
        if case let .repeated(element) = self {
            return element.repeatedElement?.unwrapped
        }
        return nil
    }
    
    /// Returns the dictionary key if `self` is `.dictionary`
    var dictionaryKey: PrimitiveType? {
        if case let .dictionary(key, _) = self {
            return key
        }
        return nil
    }
    
    /// Returns the dictionary value type if `self` is `.dictionary`
    var dictionaryValue: TypeInformation? {
        if case let .dictionary(_, value) = self {
            return value
        }
        return nil
    }
    
    /// Returns object properties if `self` is `.object`, otherwise an empty array
    var objectProperties: [TypeProperty] {
        switch self {
        case let .object(_, properties): return properties
        default: return objectType?.objectProperties ?? []
        }
    }
    
    /// Returns enum cases if `self` is `.enum`, otherwise an empty array
    var enumCases: [EnumCase] {
        if case let .enum(_, _, cases) = self {
            return cases
        }
        return []
    }
    
    /// Return rawValueType type if `self` is enum
    var rawValueType: RawValueType? {
        if case let .enum(_, rawValueType, _) = self {
            return rawValueType
        }
        return nil
    }
    
    /// Wrapps a type descriptor as an optional type. If already an optional, returns self
    var asOptional: TypeInformation {
        isOptional ? self : .optional(wrappedValue: self)
    }
    
    /// Recursively returns all types included in this `typeInformation`, e.g. primitive types, enums, objects
    ///  and nested elements in repeated types, dictionaries and optionals
    func allTypes() -> [TypeInformation] {
        var allTypes: Set<TypeInformation> = [self]
        switch self {
        case let .repeated(element):
            allTypes += element.allTypes()
        case let .dictionary(key, value):
            allTypes += .scalar(key) + value.allTypes()
        case let .optional(wrappedValue):
            allTypes += wrappedValue.allTypes()
        case let .object(_, properties):
            allTypes += properties.flatMap { $0.type.allTypes() }
        default: break
        }
        return allTypes.asArray
    }
    
    /// Returns whether the typeInformation is contained in `allTypes()` of self
    func contains(_ typeInformation: TypeInformation?) -> Bool {
        guard let typeInformation = typeInformation else {
            return false
        }
        return allTypes().contains(typeInformation)
    }
    
    /// Returns whether the `self` is contained in `allTypes()` of `typeInformation`
    func isContained(in typeInformation: TypeInformation) -> Bool {
        typeInformation.contains(self)
    }
    
    /// Filters `allTypes()` by a boolean property of `TypeInformation`
    func filter(_ keyPath: KeyPath<TypeInformation, Bool>) -> [TypeInformation] {
        allTypes().filter { $0[keyPath: keyPath] }
    }
    
    /// If `nestedType` is an object, replaces existing properties with `properties`, otherwise returns self
    func withProperties(_ properties: [TypeProperty]) -> TypeInformation {
        switch self {
        case let .repeated(element): return .repeated(element: element.withProperties(properties))
        case let .dictionary(key, value): return .dictionary(key: key, value: value.withProperties(properties))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.withProperties(properties))
        case let .object(name, _): return .object(name: name, properties: properties)
        default: return self
        }
    }
    
    /// Returns all distinct scalars in `allTypes()`
    func scalars() -> [TypeInformation] {
        filter(\.isScalar)
    }
    
    /// Returns all distinct repeated types in `allTypes()`
    func repeatedTypes() -> [TypeInformation] {
        filter(\.isRepeated)
    }
    
    /// Returns all distinct dictionaries in `allTypes()`
    func dictionaries() -> [TypeInformation] {
        filter(\.isDictionary)
    }
    
    /// Returns all distinct optionals in `allTypes()`
    func optionals() -> [TypeInformation] {
        filter(\.isOptional)
    }
    
    /// Returns all distinct enums in `allTypes()`
    func enums() -> [TypeInformation] {
        filter(\.isEnum)
    }
    
    /// Returns all distinct objects in `allTypes()`
    func objectTypes() -> [TypeInformation] {
        filter(\.isObject)
    }
    
    /// Returns unique enum and object types defined in `self`
    /// ```swift
    /// // MARK: - Code example
    /// struct Student {
    ///     let name: String
    ///     let surname: String
    ///     let uni: Uni
    /// }
    ///
    /// struct Uni {
    ///     let city: String
    ///     let name: String
    ///     let chairs: [Chair]
    /// }
    ///
    /// enum Chair {
    ///     case ls1
    ///     case other
    /// }
    ///
    /// ```
    /// Applied on `Student`, the functions returns `[.object(Student), .object(Uni), .enum(Chair)]`, respectively with
    /// the corresponding object properties and enum cases.
    func fileRenderableTypes() -> [TypeInformation] {
        filter(\.isEnumOrObject)
    }
    
    static func `enum`(name: TypeName, cases: [EnumCase]) -> TypeInformation {
        .enum(name: name, rawValueType: .string, cases: cases)
    }
    
    static func `enum`<R: RawRepresentable>(model: R.Type, cases: [EnumCase]) -> TypeInformation {
        .enum(name: .init(R.self), rawValueType: .init(R.self), cases: cases)
    }
}

// MARK: - Array extensions
public extension Array where Element == TypeInformation {
    /// Appends rhs to lhs
    static func + (lhs: Self, rhs: Element) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(rhs)
        return mutableLhs
    }
    
    /// Appends lhs to rhs
    static func + (lhs: Element, rhs: Self) -> Self {
        rhs + lhs
    }
    
    /// Appends contents of rhs to lhs
    static func + (lhs: Self, rhs: Self) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(contentsOf: rhs)
        return mutableLhs.unique()
    }
    
    /// Unique file renderable types contained in self
    func fileRenderableTypes() -> Self {
        flatMap { $0.fileRenderableTypes() }.unique()
    }
}
