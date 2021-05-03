import Foundation

extension TypeDescriptor {
    enum ResolvedType {
        case scalar
        case array
        case dictionary
        case optional
        case `enum`
        case object
    }
    
    var type: ResolvedType {
        switch self {
        case .scalar: return .scalar
        case .array: return .array
        case .dictionary: return .dictionary
        case .optional: return .optional
        case .enum: return .enum
        case .object: return .object
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
    
    var isEnum: Bool {
        type == .enum
    }
    
    var isObject: Bool {
        type == .object
    }
    
    var isComplex: Bool {
        isEnum && isObject
    }
    
    var typeName: TypeName {
        switch self {
        case let .scalar(primitiveType):
            return primitiveType.typeName
        case let .array(element):
            return element.typeName
        case let .dictionary(_, value):
            return value.typeName
        case let .optional(wrappedValue):
            return wrappedValue.typeName
        case let .enum(name, _):
            return name
        case let .object(name, _):
            return name
        }
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
            return value
        }
        return nil
    }
    
    var typeProperties: [TypeProperty] {
        switch self {
        case .array(element: let element):
            return element.typeProperties
        case .dictionary(key: _, value: let value):
            return value.typeProperties
        case .optional(wrappedValue: let wrappedValue):
            return wrappedValue.typeProperties
        case .object(name: _, properties: let properties):
            return properties
        default: return []
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
        filter(\.isEnum)
    }
    
    func objectTypes() -> [TypeDescriptor] {
        filter(\.isObject)
    }
    
    func complexTypes() -> [TypeDescriptor] {
        filter(\.isComplex)
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
