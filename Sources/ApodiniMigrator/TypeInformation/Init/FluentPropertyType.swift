import Foundation

/// Represents distinct cases of FluentKit (version: 1.12.0) property wrappers
public enum FluentPropertyType: String, Value {
    /// @Enum
    case enumProperty
    /// @OptionalEnum
    case optionalEnumProperty
    /// @Children
    case childrenProperty
    /// @Field
    case fieldProperty
    /// @ID
    case iDProperty
    /// @OptionalChild
    case optionalChildProperty
    /// @OptionalField
    case optionalFieldProperty
    /// @OptionalParent
    case optionalParentProperty
    /// @Parent
    case parentProperty
    /// @Siblings
    case siblingsProperty
    /// @Timestamp
    case timestampProperty
    /// @Group
    case groupProperty
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self).without("@").lowerFirst + "Property"
        
        guard let instance = FluentPropertyType(rawValue: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode \(Self.self)")
        }
        
        self = instance
    }
    
    /// Indicates whether the type of the property is get-only. Such fluent properties represent some kind of relationship amoung db tables
    public var isGetOnly: Bool {
        [.childrenProperty, .optionalChildProperty, .optionalParentProperty, .parentProperty, .siblingsProperty].contains(self)
    }
}

// MARK: - CustomStringConvertible + CustomDebugStringConvertible
extension FluentPropertyType: CustomStringConvertible, CustomDebugStringConvertible {
    /// String representation, e.g. `@ID`
    public var description: String {
        "@" + rawValue.upperFirst.without("Property")
    }
    
    public var debugDescription: String {
        description
    }
}
