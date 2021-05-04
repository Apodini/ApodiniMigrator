import Foundation

extension TypeDescriptor {
    /// A simplified enum of the type descriptor
    enum RootType {
        case scalar
        case array
        case dictionary
        case optional
        case `enum`
        case object
        case reference
    }
    
    /// The root type of this type descriptor
    var rootType: RootType {
        switch self {
        case .scalar: return .scalar
        case .array: return .array
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
    
    /// Indicates whether the root type is an array
    var isArray: Bool {
        rootType == .array
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
    
    /// Indicates whether the root type is a reference
    var isReference: Bool {
        rootType == .reference
    }
    
    /// If the root type is enum, returns `self`, otherwise the nested types are searched recursively
    var enumType: TypeDescriptor? {
        switch self {
        case let .array(element): return element.enumType
        case let .dictionary(_, value): return value.enumType
        case let .optional(wrappedValue): return wrappedValue.unwrapped.enumType
        case .enum: return self
        default: return nil
        }
    }
    
    /// If the root type is an object, returns `self`, otherwise the nested types are searched recursively
    var objectType: TypeDescriptor? {
        switch self {
        case let .array(element): return element.objectType
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
    
    /// Returns the nested reference if any. References can be stored inside array, dictionaries, optionals, or at top level
    var reference: TypeDescriptor? {
        switch self {
        case let .array(element): return element.reference
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
    
    /// The typeName of this type descriptor
    /// results in fatal error if requested for a `.reference`
    var typeName: TypeName {
        switch self {
        case let .scalar(primitiveType): return primitiveType.typeName
        case let .array(element): return element.typeName
        case let .dictionary(_, value): return value.typeName
        case let .optional(wrappedValue): return wrappedValue.typeName
        case let .enum(name, _): return name
        case let .object(name, _): return name
        case .reference: fatalError("Attempted to request type name from a reference")
        }
    }
    
    /// Returns the `objectProperties` by keypath
    func filterProperties(_ keyPath: KeyPath<TypeDescriptor, Bool>) -> [TypeProperty] {
        objectProperties.filter { $0.type[keyPath: keyPath] }
    }
    
    /// Indicate whether `self` has the same root type with other `typeDescriptor`
    func sameType(with typeDescriptor: TypeDescriptor) -> Bool {
        rootType == typeDescriptor.rootType
    }
    
    /// Recursively unwrappes the value of optional type if `self` is `.optional`
    var unwrapped: TypeDescriptor {
        if case let .optional(wrapped) = self {
            return wrapped.unwrapped
        }
        return self
    }
    
    /// Recursively returns the element of the array (also unwrapped)
    var arrayElement: TypeDescriptor? {
        if case let .array(element) = self {
            return element.arrayElement?.unwrapped
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
    var dictionaryValue: TypeDescriptor? {
        if case let .dictionary(_, value) = self {
            return value.dictionaryValue
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
        if case let .enum(_, cases) = self {
            return cases
        }
        return []
    }
    
    /// Recursively returns all types included in this type descriptor, e.g. primitive types, enums, objects
    ///  and nested elements in arrays, dictionaries and optionals
    func allTypes() -> [TypeDescriptor] {
        var allTypes: Set<TypeDescriptor> = [self]
        switch self {
        case let .array(element):
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
    
    /// Returns whether the typeDescriptor is contained in `allTypes()` of self
    func contains(_ typeDescriptor: TypeDescriptor?) -> Bool {
        guard let typeDescriptor = typeDescriptor else {
            return false
        }
        return allTypes().contains(typeDescriptor)
    }
    
    
    /// Returns whether the `self` is contained in `allTypes()` of `typeDescriptor`
    func isContained(in typeDescriptor: TypeDescriptor) -> Bool {
        typeDescriptor.contains(self)
    }
    
    /// Filters `allTypes()` by a boolean keypath of `TypeDescriptor`
    func filter(_ keyPath: KeyPath<TypeDescriptor, Bool>) -> [TypeDescriptor] {
        allTypes().filter { $0[keyPath: keyPath] }
    }
    
    /// Returns all distinct scalars in `allTypes()`
    func scalars() -> [TypeDescriptor] {
        filter(\.isScalar)
    }
    
    /// Returns all distinct arrays in `allTypes()`
    func arrays() -> [TypeDescriptor] {
        filter(\.isArray)
    }
    
    /// Returns all distinct dictionaries in `allTypes()`
    func dictionaries() -> [TypeDescriptor] {
        filter(\.isDictionary)
    }
    
    /// Returns all distinct optionals in `allTypes()`
    func optionals() -> [TypeDescriptor] {
        filter(\.isOptional)
    }
    
    /// Returns all distinct enums in `allTypes()`
    func enums() -> [TypeDescriptor] {
        filter(\.isEnum)
    }
    
    /// Returns all distinct objects in `allTypes()`
    func objectTypes() -> [TypeDescriptor] {
        filter(\.isObject)
    }
}

// MARK: - Array extensions
fileprivate extension Array where Element == TypeDescriptor {
    static func + (lhs: Self, rhs: Element) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(rhs)
        return mutableLhs
    }
    
    static func + (lhs: Element, rhs: Self) -> Self {
        rhs + lhs
    }
}
