//
//  TypeProperty.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object that represents a property of an `.object` TypeInformation
public struct TypeProperty: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case name, type, annotation
    }
    /// Name of the property
    public let name: String
    /// Type of the property
    public let type: TypeInformation
    /// Annotation of the property, e.g. `@Field` of Fluent property
    public let annotation: String?
    
    /// Necessity of a property
    public var necessity: Necessity {
        type.isOptional ? .optional : .required
    }
    
    /// Initializes a new `TypeProperty` instance
    public init(name: String, type: TypeInformation, annotation: String? = nil) {
        self.name = name
        self.type = type
        self.annotation = annotation
    }
    
    /// :nodoc:
    public static func == (lhs: TypeProperty, rhs: TypeProperty) -> Bool {
        lhs.name == rhs.name && lhs.type == rhs.type
    }
    
    /// Returns a version of self where the type is a reference
    public func referencedType() -> TypeProperty {
        .init(name: name, type: type.asReference(), annotation: annotation)
    }
}

// MARK: - DeltaIdentifiable
extension TypeProperty: DeltaIdentifiable {
    /// DeltaIdentifier of the property initialized from the `name`
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

// MARK: - Convenience
extension TypeProperty {
    static func property(_ name: String, type: TypeInformation) -> TypeProperty {
        .init(name: name, type: type)
    }
    
    static func fluentProperty(_ name: String, type: TypeInformation, annotation: String) -> TypeProperty {
        .init(name: name, type: type, annotation: annotation)
    }
}
