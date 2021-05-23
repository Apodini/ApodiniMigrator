//
//  File.swift
//  
//
//  Created by Eldi Cano on 28.03.21.
//

import Foundation

/// A protocol, that requires conforming objects to introduce a `DeltaIdentifier` property
public protocol DeltaIdentifiable {
    var deltaIdentifier: DeltaIdentifier { get }
}

/// A `DeltaIdentifier` uniquely identifies an object in ApodiniDelta
public struct DeltaIdentifier: Value, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    
    public init<R: RawRepresentable>(_ rawRepresentable: R) where R.RawValue == String {
        self.rawValue = rawRepresentable.rawValue
    }

    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension DeltaIdentifier: CustomStringConvertible {
    public var description: String { rawValue }
}

extension DeltaIdentifier {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension DeltaIdentifier: Comparable {
    public static func < (lhs: DeltaIdentifier, rhs: DeltaIdentifier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension DeltaIdentifier {
    public static func == (lhs: DeltaIdentifier, rhs: DeltaIdentifier) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
