//
//  Value.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A protocol that requires conformance to `Codable` and `Hashable` (also `Equatable`),
/// that most of the objects in `ApodiniDelta` conform to
public protocol Value: Codable, Hashable {}

public extension Value {
    /// Name of the type
    static var typeName: String { String(describing: Self.self) }
    
    /// The name of the type containing the name of the Module where it is defined to
    /// e.g. `Foundation.UUID`
    static var reflectingTypeName: String { String(reflecting: Self.self) }

    /// Object identifier of the type
    static var identifier: ObjectIdentifier { .init(Self.self) }
}
