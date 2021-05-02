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
    
    var dictionaryValue: TypeContainer? {
        if case let .dictionary(_, value) = self {
            return value
        }
        return nil
    }
    
    var dictionaryKey: PrimitiveType? {
        if case let .dictionary(key, _) = self {
            return key
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
    
    func sameType(with typeContainer: TypeContainer) -> Bool {
        type == typeContainer.type
    }
}
