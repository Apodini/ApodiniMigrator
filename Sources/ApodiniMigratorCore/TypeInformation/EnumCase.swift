//
//  EnumCase.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents distinct cases of raw value types of an enumeration
public enum RawValueType: String, Value, CustomStringConvertible {
    /// An integer raw value type
    case int
    /// A string raw value type
    case string
    
    /// Textual representation of `self`
    public var description: String {
        rawValue.upperFirst
    }
}

/// Represents a case of an enumeration
public struct EnumCase: Value {
    /// Name of the case
    public let name: String
    /// Raw value of the case
    public let rawValue: String
    
    /// Initializes self out of a `name`
    ///  - Note: `rawValue` is set equal to `name`
    public init(_ name: String) {
        self.name = name
        self.rawValue = name
    }
    
    /// Initializes a new instance
    public init(_ name: String, rawValue: String) {
        self.name = name
        self.rawValue = rawValue
    }
}

// MARK: - DeltaIdentifiable
extension EnumCase: DeltaIdentifiable {
    /// DeltaIdentifier of `self` initialized from the `name`
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

public extension EnumCase {
    /// Returns an enum case with named `name`
    static func `case`(_ name: String) -> EnumCase {
        .init(name)
    }
}
