//
//  Runtime.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import Runtime

/// Wrapper for `Runtime.typeInfo(of:)`
func info(of type: Any.Type) throws -> TypeInfo {
    try Runtime.typeInfo(of: type)
}

func type(_ type: Any.Type, isAnyOf kinds: Kind...) -> Bool {
    guard let kind = try? info(of: type).kind else {
        return false
    }
    return kinds.contains(kind)
}


/// Wrapper for `Runtime.createInstance(of:)`
func createInstance(of type: Any.Type) throws -> Any {
    try Runtime.createInstance(of: type)
}

/// Returns the cardinality of `type`
func cardinality(of type: Any.Type) throws -> Cardinality {
    try info(of: type).cardinality
}

/// Indicates whether `error` can be ignored during `TypeInformation` initialization
func knownRuntimeError(_ error: Error) -> Bool {
    [Runtime.Kind.opaque, .function, .existential, .metatype]
        .map { "Runtime.Kind.\($0)" }
        .contains(where: { String(describing: error).contains($0) })
}

extension URL: DefaultConstructor {
    public init() {
        self = .default
    }
}

// MARK: - TypeInfo
extension TypeInfo {
    /// TypeName of the type of the `Runtime.TypeInfo`
    var typeName: TypeName {
        .init(type)
    }
    
    /// Cardinality of `self` based on the `mangledName`
    var cardinality: Cardinality {
        let mangledName = MangledName(self.mangledName)
        if mangledName == .repeated, let elementType = genericTypes.first {
            return .repeated(elementType)
        } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
            return .optional(wrappedValueType)
        } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
            return .dictionary(key: keyType, value: valueType)
        } else { return .exactlyOne(type) }
    }
    
    /// Maps `properties` to `[RuntimeProperty]`
    func properties() throws -> [RuntimeProperty] {
        try properties.map { try .init($0) }
    }
}

// MARK: - RuntimeProperty
/// A wrapper around `Runtime.PropertyInfo` that provides additional `TypeInformation` auxilary info
struct RuntimeProperty {
    /// Name of `wrappedValue` property of property wrappers
    static let wrappedValuePropertyName = "wrappedValue"
    
    /// The corresponding `Runtime.PropertyInfo` of `self`
    let propertyInfo: PropertyInfo
    /// TypeInfo of `propertyInfo.type`
    let typeInfo: TypeInfo
    /// Name of the property
    /// - Note: if the property corresponds to a `propertyWrapper` property, leading `_` is dropped
    var name: String {
        wrappedValueProperty != nil || fluentPropertyType != nil
            ? String(propertyInfo.name.dropFirst())
            : propertyInfo.name
    }
    
    /// mangledName
    var mangledName: MangledName { .init(typeInfo.mangledName) }
    
    /// Cardinality`
    var cardinality: Cardinality { typeInfo.cardinality }
    
    /// Type of `propertyInfo.type`
    var type: Any.Type { propertyInfo.type }
    
    /// Owner type of `propertyInfo`
    var ownerType: Any.Type { propertyInfo.ownerType }
    
    /// If `propertyInfo.name` starts with `_`, returns the property of that property named `wrappedValue`, otherwise nil
    var wrappedValueProperty: RuntimeProperty? {
        if propertyInfo.name.starts(with: "_") {
           return try? typeInfo.properties().firstMatch(on: \.name, with: Self.wrappedValuePropertyName)
        }
        return nil
    }
    
    /// The type of the property wrapper wrapped value type
    var propertyWrapperWrappedValueType: Any.Type? { wrappedValueProperty?.type }
    
    /// Fluent property type if `mangledName` correspondes to the name of one of the fluent properties
    var fluentPropertyType: FluentPropertyType? {
        if case let .fluentPropertyType(fluentPropertyType) = mangledName {
            return fluentPropertyType
        }
        return nil
    }
    
    /// Indicates whether self is a fluent property
    var isFluentProperty: Bool { fluentPropertyType != nil }
    
    /// Indicates whether self is an `@ID` property
    var isIDProperty: Bool { fluentPropertyType == .iDProperty }
    
    /// Generic types of `typeInfo`
    var genericTypes: [Any.Type] { typeInfo.genericTypes }
    
    /// Initializes self out of a `Runtime.PropertyInfo`, by additionaly creating the `typeInfo` of `propertyInfo.type`
    /// - throws: if typeInfo creation fails
    init(_ propertyInfo: PropertyInfo) throws {
        self.propertyInfo = propertyInfo
        self.typeInfo = try info(of: propertyInfo.type)
    }
}
