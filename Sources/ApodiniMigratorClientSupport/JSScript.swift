//
//  JSScript.swift
//  
//
//  Created by Eldi Cano on 13.06.21.
//

import Foundation
import ApodiniMigrator

/// A `JSScript` object that holds the script function at his rawValue property
public struct JSScript: Value, RawRepresentable {
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
extension JSScript: ExpressibleByStringLiteral {
    /// Creates an instance initialized to the given string value.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - CustomStringConvertible + CustomDebugStringConvertible
extension JSScript: CustomStringConvertible, CustomDebugStringConvertible {
    /// String description of self
    public var description: String { rawValue }
    /// String description of self
    public var debugDescription: String { rawValue }
}

// MARK: - Hashable
public extension JSScript {
    /// :nodoc:
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - Equatable
public extension JSScript {
    /// :nodoc:
    static func == (lhs: JSScript, rhs: JSScript) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
