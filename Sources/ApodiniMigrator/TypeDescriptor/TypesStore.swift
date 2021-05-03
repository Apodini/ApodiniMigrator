import Foundation

struct TypesStore: Codable {
    var types: [String: TypeDescriptor]
    
    init() {
        types = [:]
    }
    
    @discardableResult
    mutating func store(_ type: TypeDescriptor) -> TypeDescriptor {
        guard type.isReferencable else {
            return type
        }
        
        let key = type.typeName.name
        
        
        if let enumType = type.enumType {
            types[key] = enumType
            return type.asReference(with: key)
        }
        
        
        if let objectType = type.objectType {
            let referencedProperties = objectType.objectProperties.map { property -> TypeProperty in
                .init(name: property.name, type: store(property.type))
            }
            
            types[key] = .object(name: objectType.typeName, properties: referencedProperties)
            return type.asReference(with: key)
        }
        
        fatalError("TypeDescriptor model is malformed")
    }
    
    mutating func construct(from reference: TypeDescriptor) -> TypeDescriptor {
        guard let referenceKey = reference.referenceKey, let stored = types[referenceKey] else {
            fatalError("No type stored with reference")
        }
        
        switch stored {
        case .enum:
            return stored
        case let .object(name, properties):
            let newProperties = properties.map { property -> TypeProperty in
                if let reference = property.type.reference {
                    return self.property(type: property, from: reference)
                }
                return property
            }
            return .object(name: name, properties: newProperties)
        default: fatalError("Encountered a non referencable type \(stored.typeName.name)")
        }
    }
    
    mutating func stored(type: TypeDescriptor, with reference: TypeDescriptor) -> TypeDescriptor {
        switch reference {
        case .array(element: let element):
            return .array(element: type)
        case .dictionary(key: let key, value: let value):
            return .dictionary(key: key, value: type)
        case .optional(wrappedValue: let wrappedValue):
            return .optional(wrappedValue: type)
        
        default: fatalError(" errorr")
        }
    }
    
    mutating func property(type: TypeProperty, from reference: TypeDescriptor) -> TypeProperty {
        let propertyName = type.name
        let adjusted = construct(from: reference)
        let newPropertyType: TypeDescriptor
        switch type.type {
        case .array: newPropertyType = .array(element: adjusted)
        case let .dictionary(dictionaryKey, _): newPropertyType = .dictionary(key: dictionaryKey, value: adjusted)
        case .optional: newPropertyType = .optional(wrappedValue: adjusted)
        case .enum: newPropertyType = adjusted
        case .object: newPropertyType = adjusted
        case .reference: newPropertyType = adjusted
        default: fatalError(" Error")
        }
        return .init(name: propertyName, type: newPropertyType)
    }
}

fileprivate extension TypeDescriptor {
    func asReference(with key: String) -> TypeDescriptor {
        switch self {
        case .scalar: return self
        case let .array(element): return .array(element: element.asReference(with: key))
        case let .dictionary(dictionaryKey, value): return .dictionary(key: dictionaryKey, value: value.asReference(with: key))
        case let .optional(wrappedValue):
            
            return .optional(wrappedValue: wrappedValue.asReference(with: key))
        case .enum, .object: return .reference(key)
        case .reference: fatalError("Attempted to create a reference from a reference")
        }
    }
    
    func inject(type: TypeDescriptor) -> TypeDescriptor {
        guard type != self else {
            return self
        }
        
        switch self {
        case .optional: return .optional(wrappedValue: type)
        case .array: return .array(element: type)
        case let .dictionary(key, _): return .dictionary(key: key, value: type)
        case .enum: return type
        case .object: return type
        default: return self
        }
    }
}
