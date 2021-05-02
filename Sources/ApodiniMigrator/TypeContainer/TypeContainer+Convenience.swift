import Foundation

extension TypeContainer {
    enum ResolvedType {
        case primitive
        case array
        case dictionary
        case optional
        case `enum`
        case complex
    }
    
    var type: ResolvedType {
        switch self {
        case .primitive: return .primitive
        case .array: return .array
        case .dictionary: return .dictionary
        case .optional: return .optional
        case .enum: return .enum
        case .complex: return .complex
        }
    }
    
    var isPrimitive: Bool {
        type == .primitive
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
    
    var isComplex: Bool {
        type == .complex
    }
    
    var schemaName: SchemaName {
        switch self {
        case let .primitive(primitiveType):
            return primitiveType.schemaName
        case let .array(element):
            return element.schemaName
        case let .dictionary(_, value):
            return value.schemaName
        case let .optional(wrappedValue):
            return wrappedValue.schemaName
        case let .enum(name, _):
            return name
        case let .complex(name, _):
            return name
        }
    }
    
    func sameType(with typeContainer: TypeContainer) -> Bool {
        type == typeContainer.type
    }
    
    var unwrapped: TypeContainer {
        if case let .optional(wrapped) = self {
            return wrapped
        }
        return self
    }
    
    var arrayElement: TypeContainer? {
        if case let .array(element) = self {
            return element
        }
        return nil
    }
    
    var dictionaryKey: PrimitiveType? {
        if case let .dictionary(key, _) = self {
            return key
        }
        return nil
    }
    
    var dictionaryValue: TypeContainer? {
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
        case .complex(name: _, properties: let properties):
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
    
    func allTypes() -> [TypeContainer] {
        var allTypes: Set<TypeContainer> = [self]
        switch self {
        case .array(element: let element):
            allTypes += element.allTypes()
        case .dictionary(key: let key, value: let value):
            allTypes += .primitive(key) + value.allTypes()
        case .optional(wrappedValue: let wrappedValue):
            allTypes += wrappedValue.allTypes()
        case .complex(name: _, properties: let properties):
            allTypes += properties.flatMap { $0.type.allTypes() }
        default: break
        }
        return allTypes.asArray
    }
    
    func contains(_ typeContainer: TypeContainer?) -> Bool {
        guard let typeContainer = typeContainer else { return false }
        return allTypes().contains(typeContainer)
    }
    
    func isContained(in typeContainer: TypeContainer) -> Bool {
        typeContainer.contains(self)
    }
    
    func filter(_ keyPath: KeyPath<TypeContainer, Bool>) -> [TypeContainer] {
        allTypes().filter { $0[keyPath: keyPath] }
    }
    
    func primitives() -> [TypeContainer] {
        filter(\.isPrimitive)
    }
    
    func arrays() -> [TypeContainer] {
        filter(\.isArray)
    }
    
    func dictionaries() -> [TypeContainer] {
        filter(\.isDictionary)
    }
    
    func optionals() -> [TypeContainer] {
        filter(\.isOptional)
    }
    
    func enums() -> [TypeContainer] {
        filter(\.isEnum)
    }
    
    func complexTypes() -> [TypeContainer] {
        filter(\.isComplex)
    }
}

fileprivate extension Array where Element == TypeContainer {
    static func + (lhs: Self, rhs: Element) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(rhs)
        return mutableLhs
    }
    
    static func + (lhs: Element, rhs: Self) -> Self {
        return rhs + lhs
    }
}
