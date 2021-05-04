import Foundation

struct TypesStore: Codable {
    /// Stored references of enums and objects
    /// Properties of objects are recursivly stored
    var types: [String: TypeDescriptor]
    
    /// Initializes a store with no types
    init() {
        types = [:]
    }
    
    /// Stores an enum or object type by its type name, and returns the reference
    /// If attempting to store a non referencable type, the operation is ignored and the input type is returned directly
    mutating func store(_ type: TypeDescriptor) -> TypeDescriptor {
        guard type.isReferencable else {
            return type
        }
        
        /// TODO unique key would be `absolutName` of typeName which includes the module
        /// e.g. `ApodiniMigrator/TypesStore`, currently only using `TypeStore`
        let key = ReferenceKey(type.typeName.name)
        
        if let enumType = type.enumType { // retrieving the nested enum
            types[key.rawValue] = enumType
        }
        
        if let objectType = type.objectType { // retrieving the nested enum
            let referencedProperties = objectType.objectProperties.map { property -> TypeProperty in
                .init(name: property.name, type: store(property.type)) // storing potentially referencable properties
            }
            types[key.rawValue] = .object(name: objectType.typeName, properties: referencedProperties)
        }
        
        return type.asReference(with: key) // referencing the type
    }
    
    /// Constructs a type from a reference
    mutating func construct(from reference: TypeDescriptor) -> TypeDescriptor {
        guard let referenceKey = reference.referenceKey, var stored = types[referenceKey.rawValue] else {
            fatalError("Attempted to construct a type that does not contain a reference")
        }
        
        /// If the stored type is an object, we recursively construct its properties and update the stored
        if case let .object(name, properties) = stored {
            let newProperties = properties.map { property -> TypeProperty in
                if let propertyReference = property.type.reference {
                    return .init(name: property.name, type: property.type.construct(from: propertyReference, in: &self))
                }
                return property
            }
            stored = .object(name: name, properties: newProperties)
        }
        
        switch reference {
        /// If the reference is at root, means the stored object has either been an object or enum -> return directly
        case .reference: return stored
        /// otherwise the stored object has been nested -> construct recursively
        case let .array(element): return .array(element: element.construct(from: reference, in: &self))
        case let .dictionary(key, value): return .dictionary(key: key, value: value.construct(from: reference, in: &self))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.construct(from: reference, in: &self))
        default: fatalError("Encountered an invalid reference \(reference)")
        }
    }
}

fileprivate extension TypeDescriptor {
    /// Wraps the element into a reference, e.g. .array(User) -> .array(.reference(User)) after all properties of user have been stored
    func asReference(with key: ReferenceKey) -> TypeDescriptor {
        switch self {
        case let .array(element): return .array(element: element.asReference(with: key))
        case let .dictionary(dictionaryKey, value): return .dictionary(key: dictionaryKey, value: value.asReference(with: key))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.asReference(with: key))
        case .enum, .object: return .reference(key)
        default: fatalError("Attempted to create a reference from a non referencable type")
        }
    }
    
    /// Used to construct properties of object types recursively
    func construct(from reference: TypeDescriptor, in store: inout TypesStore) -> TypeDescriptor {
        switch self {
        case let .array(element): return .array(element: element.construct(from: reference, in: &store))
        case let .dictionary(key, value): return .dictionary(key: key, value: value.construct(from: reference, in: &store))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.construct(from: reference, in: &store))
        // initial reference has been recursively deconstructed until here -> construct from self
        case .reference: return store.construct(from: self)
        default: fatalError("Attempted to construct a non referencable type")
        }
    }
}
