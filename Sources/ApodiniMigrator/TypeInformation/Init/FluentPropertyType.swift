//
//  File.swift
//  
//
//  Created by Eldi Cano on 29.05.21.
//

import Foundation

/// Represents distinct cases of FluentKit (version: 1.12.0) property wrappers
enum FluentPropertyType: String {
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
    
    /// Indicates whether the type of the property might introduce some kind of relationship
    var isRelationshipProperty: Bool {
        [.childrenProperty, .optionalChildProperty, .optionalParentProperty, .parentProperty, .siblingsProperty].contains(self)
    }
}
