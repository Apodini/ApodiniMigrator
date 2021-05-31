//
//  Status.swift
//
//  Created by ApodiniMigrator on 31.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public enum Status: String, Codable, CaseIterable {
    case created = "created"
    case noContent = "noContent"
    case ok = "ok"
    
    // MARK: - Deprecated
    private static let deprecatedCases: [Self] = []
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(encodableValue().rawValue)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        self = Self(rawValue: try decoder.singleValueContainer().decode(RawValue.self)) ?? .created
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
