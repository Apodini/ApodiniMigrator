//
//  TypeProperty.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public struct TypeProperty: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case name, type, annotation
    }
    public let name: String
    public let type: TypeInformation
    public let annotation: String?
    
    public var necessity: Necessity {
        type.isOptional ? .optional : .required
    }
    
    init(name: String, type: TypeInformation, annotation: String? = nil) {
        self.name = name
        self.type = type
        self.annotation = annotation
    }
    
    public init(name: String, type: TypeInformation) {
        self.name = name
        self.type = type
        self.annotation = nil
    }
    
    public static func == (lhs: TypeProperty, rhs: TypeProperty) -> Bool {
        lhs.name == rhs.name && lhs.type == rhs.type
    }
}

extension TypeProperty: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

extension TypeProperty {
    static func property(_ name: String, type: TypeInformation) -> TypeProperty {
        .init(name: name, type: type)
    }
    
    static func fluentProperty(_ name: String, type: TypeInformation, annotation: String) -> TypeProperty {
        .init(name: name, type: type, annotation: annotation)
    }
}
