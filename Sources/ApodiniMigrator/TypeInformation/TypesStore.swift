import Foundation

/// `TypesStore` provides logic to reference and store `typeInformation` instances, while e.g. an endpoint keeps only the reference of the response type
/// Provided with a reference from `TypeStore`, the instance of `typeInformation`
/// can be constructed without information-loss via `construct(from reference:)`
public struct TypesStore: Codable {
    /// Stored references of enums and objects
    /// Properties of objects are recursively stored
    public var storage: [String: TypeInformation]
    
    /// Initializes a store with an empty storage
    public init() {
        storage = [:]
    }
    
    /// Stores an enum or object type by its type name, and returns the reference
    /// If attempting to store a non referencable type, the operation is ignored and the input type is returned directly
    public mutating func store(_ type: TypeInformation) -> TypeInformation {
        guard type.isReferencable else {
            return type
        }
        
        #warning(
            """
            unique key must be `absoluteName` of typeName which includes the module,
            e.g. `ApodiniMigrator/User`, currently only using type name `User`
            """)
        let key = ReferenceKey(type.typeName.name)
        
        if let enumType = type.enumType { // retrieving the nested enum
            storage[key.rawValue] = enumType
        }
        
        if let objectType = type.objectType { // retrieving the nested object
            let referencedProperties = objectType.objectProperties.map { property -> TypeProperty in
                .init(name: property.name, type: store(property.type)) // storing potentially referencable properties
            }
            storage[key.rawValue] = .object(name: objectType.typeName, properties: referencedProperties)
        }
        
        return type.asReference(with: key) // referencing the type
    }
    
    /// Constructs a type from a reference
    public mutating func construct(from reference: TypeInformation) -> TypeInformation {
        guard let referenceKey = reference.referenceKey, var stored = storage[referenceKey.rawValue] else {
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
        case let .repeated(element): return .repeated(element: element.construct(from: reference, in: &self))
        case let .dictionary(key, value): return .dictionary(key: key, value: value.construct(from: reference, in: &self))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.construct(from: reference, in: &self))
        default: fatalError("Encountered an invalid reference \(reference)")
        }
    }
}

fileprivate extension TypeInformation {
    /// Wraps the element into a reference, e.g. .repeated(User) -> .repeated(.reference(User)) after all properties of user have been stored
    func asReference(with key: ReferenceKey) -> TypeInformation {
        switch self {
        case let .repeated(element): return .repeated(element: element.asReference(with: key))
        case let .dictionary(dictionaryKey, value): return .dictionary(key: dictionaryKey, value: value.asReference(with: key))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.asReference(with: key))
        case .enum, .object: return .reference(key)
        default: fatalError("Attempted to create a reference from a non referencable type")
        }
    }
    
    /// Used to construct properties of object or enum types recursively
    func construct(from reference: TypeInformation, in store: inout TypesStore) -> TypeInformation {
        switch self {
        case let .repeated(element): return .repeated(element: element.construct(from: reference, in: &store))
        case let .dictionary(key, value): return .dictionary(key: key, value: value.construct(from: reference, in: &store))
        case let .optional(wrappedValue): return .optional(wrappedValue: wrappedValue.construct(from: reference, in: &store))
        // initial reference has been recursively deconstructed until here -> construct from self
        case .reference: return store.construct(from: self)
        default: fatalError("Attempted to construct a non referencable type")
        }
    }
}
