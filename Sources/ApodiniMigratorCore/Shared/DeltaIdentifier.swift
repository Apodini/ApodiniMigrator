//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol, that requires conforming objects to introduce a `DeltaIdentifier` property
public protocol DeltaIdentifiable {
    /// Delta identifier
    var deltaIdentifier: DeltaIdentifier { get }
}

/// A `DeltaIdentifier` uniquely identifies an object in ApodiniDelta
public struct DeltaIdentifier: Value, RawRepresentable {
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
        try rawValue = decoder.singleValueContainer().decode(String.self)
    }

    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public extension Array where Element: DeltaIdentifiable {
    /// Returns the mapped identifiers of the elements
    func identifiers() -> [DeltaIdentifier] {
        map { $0.deltaIdentifier }
    }
}

// MARK: - ExpressibleByStringLiteral
extension DeltaIdentifier: ExpressibleByStringLiteral {
    /// Creates an instance initialized to the given string value.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - ExpressibleByStringInterpolation
extension DeltaIdentifier: ExpressibleByStringInterpolation {}

extension DeltaIdentifier: CustomStringConvertible {
    /// String representation of self
    public var description: String { rawValue }
}

extension DeltaIdentifier {
    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension DeltaIdentifier: Comparable {
    /// :nodoc:
    public static func < (lhs: DeltaIdentifier, rhs: DeltaIdentifier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension DeltaIdentifier {
    /// :nodoc:
    public static func == (lhs: DeltaIdentifier, rhs: DeltaIdentifier) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
