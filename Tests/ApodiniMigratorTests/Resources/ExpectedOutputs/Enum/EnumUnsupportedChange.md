//
//  ProgLang.swift
//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
@available(*, deprecated, message: "Unsupported change! Raw value type changed")
public enum ProgLang: String, Codable, CaseIterable {
    case java
    case javaScript
    case objectiveC
    case other
    case python
    case ruby
    case swift
    
    // MARK: - Deprecated
    private static let deprecatedCases: [Self] = []
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(try encodableValue().rawValue)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        self = Self(rawValue: try decoder.singleValueContainer().decode(RawValue.self)) ?? .java
    }
    
    // MARK: - Utils
    private func encodableValue() throws -> Self {
        let deprecated = Self.deprecatedCases
        guard deprecated.contains(self) else {
            return self
        }
        if let alternativeCase = Self.allCases.first(where: { !deprecated.contains($0) }) {
            return alternativeCase
        }
        throw ApodiniError(code: 404, message: "The web service does not support the cases of this enum anymore")
    }
}

// MARK: - CustomStringConvertible
extension ProgLang: CustomStringConvertible {
    /// Textual representation
    public var description: String {
        rawValue.description
    }
}

// MARK: - LosslessStringConvertible
extension ProgLang: LosslessStringConvertible {
    /// Instantiates an instance of the conforming type from a string representation.
    public init?(_ description: String) {
        self.init(rawValue: description)
    }
}
