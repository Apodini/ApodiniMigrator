//
//  InstanceCreator.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Distinct cases of errors that can be thrown from `InstanceCreator`
enum InstanceCreatorError: Swift.Error {
    case nonSupportedDictionaryKey(Any.Type)
    case failedCastingInstanceToType
}

/// Creates an instance out of a type
struct InstanceCreator {
    /// The instance that has been created
    var instance: Any
    
    /// Initalizes self out of `type` and stores the created instance in `instance`
    init(for type: Any.Type) throws {
        if let defaultInitializableType = type as? DefaultInitializable.Type {
            instance = defaultInitializableType.init(.default)
            return
        }
        
        let typeInfo = try info(of: type)
        let cardinality = typeInfo.cardinality
        
        // making sure to initialize with at least one element for arrays, optionals and dictionaries
        if case let .repeated(elementType) = cardinality {
            instance = [try Self(for: elementType).instance]
        } else if case let .optional(wrappedValueType) = cardinality {
            instance = try Self(for: wrappedValueType).instance
        } else if case let .dictionary(keyType, valueType) = cardinality {
            guard let primitiveKeyType = PrimitiveType(keyType) else {
                throw InstanceCreatorError.nonSupportedDictionaryKey(keyType)
            }
            instance = try Self.dictionaryInstance(for: primitiveKeyType, and: valueType)
        } else {
            instance = try createInstance(of: type) // the actual call on create instance
            try handleEmptyProperties(try typeInfo.properties()) // handling potential empty properties
        }
    }
    
    /// Ensures to initialize potential empty properties such as arrays, dictionaries and optionals
    private mutating func handleEmptyProperties(_ properties: [RuntimeProperty]) throws {
        try properties.forEach {
            try handleRepeated(on: $0)
            try handleDictionary(on: $0)
            try handleOptional(on: $0)
            try handlePropertyWrapper(on: $0)
            try handleFluentProperty(on: $0)
        }
    }
    
    /// Handles empty array property by initializing it with one element
    private mutating func handleRepeated(on property: RuntimeProperty) throws {
        if case let .repeated(elementType) = property.cardinality {
            let propertyInstance = try Self(for: elementType).instance
            try property.propertyInfo.set(value: [propertyInstance], on: &instance)
        }
    }
    
    /// Handles empty dictionary property by initializing it with one element
    private mutating func handleDictionary(on property: RuntimeProperty) throws {
        if case let .dictionary(keyType, valueType) = property.cardinality {
            guard let primitiveKey = PrimitiveType(keyType) else {
                throw InstanceCreatorError.nonSupportedDictionaryKey(keyType)
            }
            let propertyInstance = try Self.dictionaryInstance(for: primitiveKey, and: valueType)
            try property.propertyInfo.set(value: propertyInstance, on: &instance)
        }
    }
    
    /// Handles `.none` optional property by initializing it with `.some(wrapped)`
    private mutating func handleOptional(on property: RuntimeProperty) throws {
        if case let .optional(wrappedValueType) = property.cardinality {
            let propertyInstance = try Self(for: wrappedValueType).instance
            try property.propertyInfo.set(value: propertyInstance, on: &instance)
        }
    }
    
    // TODO remove / used for test case
    static var testValue: Any?
    
    /// Handles potential property wrapper property. Initializes the wrappedValue of the property wrapper
    private mutating func handlePropertyWrapper(on property: RuntimeProperty) throws {
        if let wrappedValueProperty = property.wrappedValueProperty {
            let wrappedValueInstance = try Self(for: wrappedValueProperty.type).instance
            try wrappedValueProperty.propertyInfo.set(value: Self.testValue ?? wrappedValueInstance, on: &instance)
        }
    }
    
    /// Attempt to handle initialization of fluent property
    /// - Note: `wrappedValue` of fluent property wrappers is not detected from `Runtime.typeInfo(of:)`
    /// and this function has no effect on Fluent models currently
    private mutating func handleFluentProperty(on property: RuntimeProperty) throws {
        guard property.fluentPropertyType?.isGetOnly == false else {
            return
        }
        
        try handlePropertyWrapper(on: property)
    }
    
    /// Returns typed instance
    /// - throws: if casting to `T` fails
    fileprivate func typedInstance<T>(_ type: T.Type) throws -> T {
        guard let instance = instance as? T else {
            throw InstanceCreatorError.failedCastingInstanceToType
        }
        return instance
    }
}

// MARK: - Dictionary init
extension InstanceCreator {
    static func dictionaryInstance(for key: PrimitiveType, and valueType: Any.Type) throws -> Any {
        let valueInstance = try Self(for: valueType).instance
        switch key {
        case .null: return [Null(): valueInstance]
        case .bool: return [Bool(): valueInstance]
        case .int: return [Int(): valueInstance]
        case .int8: return [Int8(): valueInstance]
        case .int16: return [Int16(): valueInstance]
        case .int32: return [Int32(): valueInstance]
        case .int64: return [Int64(): valueInstance]
        case .uint: return [UInt(): valueInstance]
        case .uint8: return [UInt8(): valueInstance]
        case .uint16: return [UInt16(): valueInstance]
        case .uint32: return [UInt32(): valueInstance]
        case .uint64: return [UInt64(): valueInstance]
        case .string: return [String(): valueInstance]
        case .double: return [Double(): valueInstance]
        case .float: return [Float(): valueInstance]
        case .url: return [URL.default: valueInstance]
        case .uuid: return [UUID(): valueInstance]
        case .date: return [Date(): valueInstance]
        case .data: return [Data(): valueInstance]
        }
    }
}

/// Creates an instance casts an instance of type `T`
/// - Throws: if instance creation or casting fails
func typedInstance<T>(_ type: T.Type) throws -> T {
    try InstanceCreator(for: type).typedInstance(T.self)
}

/// Creates an instance out of any type
func instance(_ type: Any.Type) throws -> Any {
    try InstanceCreator(for: type).instance
}
