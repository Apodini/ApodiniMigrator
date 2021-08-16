//
//  ReferenceKey.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A `ReferenceKey` uniquely identifies a `typeInformation` from the name of the type
public struct ReferenceKey: Value, RawRepresentable {
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

// MARK: - Hashable
public extension ReferenceKey {
    /// :nodoc:
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - Equatable
public extension ReferenceKey {
    /// :nodoc:
    static func == (lhs: ReferenceKey, rhs: ReferenceKey) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
