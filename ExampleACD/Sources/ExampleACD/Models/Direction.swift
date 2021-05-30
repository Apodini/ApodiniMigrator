//
//  Direction.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public enum Direction: String, Codable, CaseIterable {
    case left = "left"
    case right = "right"
    
    // MARK: - Deprecated
    private static let deprecatedCases: [Self] = []
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(encodableValue().rawValue)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        self = Self(rawValue: try decoder.singleValueContainer().decode(RawValue.self)) ?? .left
    }
    
    // MARK: - Utils
    private func encodableValue() -> Self {
        let deprecated = Self.deprecatedCases
        guard deprecated.contains(self) else {
            return self
        }
        if let alternativeCase = Self.allCases.first(where: { !deprecated.contains($0) }) {
            return alternativeCase
        }
        fatalError("The web service does not support the cases of this enum anymore")
    }
}
