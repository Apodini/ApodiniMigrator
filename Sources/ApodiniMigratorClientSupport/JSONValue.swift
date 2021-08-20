//
//  JSONValue.swift
//  ApodiniMigratorClientSupport
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ApodiniMigratorCore

/// A `JSONValue` object that holds the string json of a certain encodable instance at rawValue property
public struct JSONValue: Codable, RawRepresentable {
    /// Raw value
    public let rawValue: String

    /// Initializes self from a rawValue
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Initializes self from a rawValue
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - ExpressibleByStringLiteral
extension JSONValue: ExpressibleByStringLiteral {
    /// Creates an instance initialized to the given string value.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - Equatable
extension JSONValue: Equatable {
    /// :nodoc:
    public static func == (lhs: JSONValue, rhs: JSONValue) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
