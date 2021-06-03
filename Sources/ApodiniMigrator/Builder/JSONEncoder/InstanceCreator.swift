//
//  File.swift
//
//
//  Created by Eldi Cano on 03.06.21.
//

import Foundation

enum InstanceCreatorError: Swift.Error {
    case nonSupportedDictionaryKey(Any.Type)
    case failedCastingInstanceToEncodable
}

/// Creates an instance out of a type
struct InstanceCreator {
    
    /// The instance that has been created
    var instance: Any
    
    /// Initializer out of a type
    init(for type: Any.Type) throws {
        if let type = type as? DefaultInitializable.Type {
            instance = type.init()
            return
        }
        
        let typeInfo = try info(of: type)
        let cardinality = typeInfo.cardinality
        let genericTypes = typeInfo.genericTypes
        
        // making sure to initialize with at least one element for arrays, optionals and dictionaries
        if cardinality.isRepeated, let elementType = genericTypes.first {
            instance = [try Self(for: elementType).instance]
        } else if cardinality.isOptional, let wrappedValueType = genericTypes.first {
            instance = try Self(for: wrappedValueType).instance
        } else if cardinality.isDictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
            guard let primitiveKeyType = PrimitiveType(keyType) else {
                throw InstanceCreatorError.nonSupportedDictionaryKey(keyType)
            }
            instance = try Self.dictionaryInstance(for: primitiveKeyType, and: valueType)
        } else {
            instance = try createInstance(of: type) // the actual call on create instance
            try handleEmptyProperties(try typeInfo.properties()) // handling potential empty properties
        }
    }
    
    private mutating func handleEmptyProperties(_ properties: [RuntimeProperty]) throws {
        try properties.forEach {
            try handleRepeated(on: $0)
            try handleDictionary(on: $0)
            try handleOptional(on: $0)
            try handlePropertyWrapper(on: $0)
            try handleFluentProperty(on: $0)
        }
    }
    
    private mutating func handleRepeated(on property: RuntimeProperty) throws {
        if property.caridinality.isRepeated, let elementType = property.genericTypes.first {
            let propertyInstance = try Self(for: elementType).instance
            try property.propertyInfo.set(value: [propertyInstance], on: &instance)
        }
    }
    
    private mutating func handleDictionary(on property: RuntimeProperty) throws {
        if property.caridinality.isDictionary, let keyType = property.genericTypes.first, let valueType = property.genericTypes.last {
            guard let primitiveKey = PrimitiveType(keyType) else {
                throw InstanceCreatorError.nonSupportedDictionaryKey(keyType)
            }
            let propertyInstance = try Self.dictionaryInstance(for: primitiveKey, and: valueType)
            try property.propertyInfo.set(value: propertyInstance, on: &instance)
        }
    }
    
    private mutating func handleOptional(on property: RuntimeProperty) throws {
        if property.caridinality.isOptional, let wrappedValueType = property.genericTypes.first {
            let propertyInstance = try Self(for: wrappedValueType).instance
            try property.propertyInfo.set(value: propertyInstance, on: &instance)
        }
    }
    
    // TODO remove / used for test case
    static var testValue: Any?
    
    private mutating func handlePropertyWrapper(on property: RuntimeProperty) throws {
        if property.propertyInfo.name.starts(with: "_"), let wrappedValueProperty = try? property.typeInfo.properties().firstMatch(on: \.name, with: "wrappedValue") {
            let wrappedValueInstance = try Self(for: wrappedValueProperty.type).instance
            try wrappedValueProperty.propertyInfo.set(value: Self.testValue ?? wrappedValueInstance, on: &instance)
        }
    }
    
    private mutating func handleFluentProperty(on property: RuntimeProperty) throws {
        guard property.fluentPropertyType?.isGetOnly == false else {
            return
        }
        
        try handlePropertyWrapper(on: property)
    }
    
    func typedInstance<T: Encodable>(_ type: T.Type) throws -> T {
        guard let instance = instance as? T else {
            throw InstanceCreatorError.failedCastingInstanceToEncodable
        }
        return instance
    }
}

extension InstanceCreator {
    static func dictionaryInstance(for key: PrimitiveType, and valueType: Any.Type) throws -> Any {
        let valueInstance = try Self(for: valueType).instance
        switch key {
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
        case .url: return [URL(): valueInstance]
        case .uuid: return [UUID(): valueInstance]
        case .date: return [Date(): valueInstance]
        case .data: return [Data(): valueInstance]
        }
    }
}

/// Creates an instance out of an encodable type
func encodableInstance<T: Encodable>(_ type: T.Type) throws -> T {
    try InstanceCreator(for: type).typedInstance(T.self)
}

/// Creates an instance out of any type
func instance(_ type: Any.Type) throws -> Any {
    try InstanceCreator(for: type)
}
