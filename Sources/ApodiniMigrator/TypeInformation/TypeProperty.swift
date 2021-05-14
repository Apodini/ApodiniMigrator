import Foundation

public class PropertyName: PropertyValueWrapper<String> {}

public struct TypeProperty: Value {
    public let name: PropertyName
    public let type: TypeInformation
}

public extension TypeInformation {
    var propertyTypeString: String {
        switch self {
        case let .scalar(primitiveType): return primitiveType.description
        case let .repeated(element): return "[\(element.propertyTypeString)]"
        case let .dictionary(key, value): return "[\(key.description): \(value.propertyTypeString)]"
        case .optional(wrappedValue: let wrappedValue): return wrappedValue.propertyTypeString + "?"
        case let .enum(name, _): return name.name
        case let .object(name, _): return name.name
        case .reference: fatalError("Attempted to request property type string from a reference")
        }
    }
}

public struct EnumCase: Value {
    public let name: PropertyName
    public let type: TypeInformation // currently only .scalar(.string)
    
    public init(_ name: String) {
        self.name = .init(name)
        self.type = .scalar(.string)
    }
}
