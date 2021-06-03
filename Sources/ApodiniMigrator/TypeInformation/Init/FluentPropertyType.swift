//
//  File.swift
//  
//
//  Created by Eldi Cano on 29.05.21.
//

import Foundation

/// Represents distinct cases of FluentKit (version: 1.12.0) property wrappers
public enum FluentPropertyType: String, Codable {
    case enumProperty
    case optionalEnumProperty
    case childrenProperty
    case fieldProperty
    case iDProperty
    case optionalChildProperty
    case optionalFieldProperty
    case optionalParentProperty
    case parentProperty
    case siblingsProperty
    case timestampProperty
    case groupProperty
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode("@" + rawValue.without("Property").upperFirst)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self).without("@").lowerFirst + "Property"
        
        guard let instance = FluentPropertyType(rawValue: string) else {
            fatalError("Failed to decode \(Self.self)")
        }
        
        self = instance
    }
    
    /// Indicates whether the type of the property is get-only. Such fluent properties represent some kind of relationship amoung db tables
    var isGetOnly: Bool {
        [.childrenProperty, .optionalChildProperty, .optionalParentProperty, .parentProperty, .siblingsProperty].contains(self)
    }
}
