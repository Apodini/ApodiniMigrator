import Foundation

extension TypeDescriptor {
    enum ResolvedType {
        case scalar
        case array
        case dictionary
        case optional
        case `enum`
        case object
        case reference
    }
    
    var type: ResolvedType {
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
    
    var isScalar: Bool {
        type == .scalar
    }
    
    var isArray: Bool {
        type == .array
    }
    
    var isDictionary: Bool {
        type == .dictionary
    }
    
    var isOptional: Bool {
        type == .optional
    }
    
    var isObject: Bool {
        type == .object
    }
    
    var isReference: Bool {
        type == .reference
    }
    
    var enumType: TypeDescriptor? {
        switch self {
        case let .array(element): return element.enumType
        case let .dictionary(_, value): return value.enumType
        case let .optional(wrappedValue): return wrappedValue.unwrapped.enumType
        case .enum: return self
        default: return nil
        }
    }
    
    var objectType: TypeDescriptor? {
        switch self {
        case let .array(element): return element.objectType
        case let .dictionary(_, value): return value.objectType
        case let .optional(wrappedValue): return wrappedValue.objectType
        case .object: return self
        default: return nil
        }
    }

    var referenceKey: String? {
        if case let .reference(key) = reference {
            return key
        }
        return nil
    }
    
    var reference: TypeDescriptor? {
        switch self {
        case let .array(element): return element.reference
        case let .dictionary(_, value): return value.reference
        case let .optional(wrappedValue): return wrappedValue.reference
        case .reference: return self
        default: return nil
        }
    }
    
    var elementIsObject: Bool {
        objectType != nil
    }
    
    var elementIsEnum: Bool {
        enumType != nil
    }
    
    var isReferencable: Bool {
        elementIsObject || elementIsEnum
    }
    
    var typeName: TypeName {
        switch self {
        case let .scalar(primitiveType): return primitiveType.typeName
        case let .array(element): return element.typeName
        case let .dictionary(_, value): return value.typeName
        case let .optional(wrappedValue): return wrappedValue.typeName
        case let .enum(name, _): return name
        case let .object(name, _): return name
        case let .reference(reference): return .init(name: reference)
        }
    }
    
    func filterProperties(_ keyPath: KeyPath<TypeDescriptor, Bool>) -> [TypeProperty] {
        objectProperties.filter { $0.type[keyPath: keyPath] }
    }
    
    func sameType(with typeDescriptor: TypeDescriptor) -> Bool {
        type == typeDescriptor.type
    }
    
    var unwrapped: TypeDescriptor {
        if case let .optional(wrapped) = self {
            return wrapped.unwrapped
        }
        return self
    }
    
    var arrayElement: TypeDescriptor? {
        if case let .array(element) = self {
            return element.arrayElement
        }
        return nil
    }
    
    var dictionaryKey: PrimitiveType? {
        if case let .dictionary(key, _) = self {
            return key
        }
        return nil
    }
    
    var dictionaryValue: TypeDescriptor? {
        if case let .dictionary(_, value) = self {
            return value.dictionaryValue
        }
        return nil
    }
    
    var objectProperties: [TypeProperty] {
        switch self {
        case let .object(_, properties): return properties
        default: return objectType?.objectProperties ?? []
        }
    }
    
    var enumCases: [EnumCase] {
        if case let .enum(_, cases) = self {
            return cases
        }
        return []
    }
    
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
    
    func contains(_ typeDescriptor: TypeDescriptor?) -> Bool {
        guard let typeDescriptor = typeDescriptor else {
            return false
        }
        return allTypes().contains(typeDescriptor)
    }
    
    func isContained(in typeDescriptor: TypeDescriptor) -> Bool {
        typeDescriptor.contains(self)
    }
    
    func filter(_ keyPath: KeyPath<TypeDescriptor, Bool>) -> [TypeDescriptor] {
        allTypes().filter { $0[keyPath: keyPath] }
    }
    
    func scalars() -> [TypeDescriptor] {
        filter(\.isScalar)
    }
    
    func arrays() -> [TypeDescriptor] {
        filter(\.isArray)
    }
    
    func dictionaries() -> [TypeDescriptor] {
        filter(\.isDictionary)
    }
    
    func optionals() -> [TypeDescriptor] {
        filter(\.isOptional)
    }
    
    func enums() -> [TypeDescriptor] {
        filter(\.elementIsEnum).filter { $0.type == .enum }
    }
    
    func objectTypes() -> [TypeDescriptor] {
        filter(\.elementIsObject).filter { $0.type == .object }
    }
}

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
