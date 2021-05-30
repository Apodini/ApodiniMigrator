//
//  Tag.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public final class Tag: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case planets = "planets"
    }
    
    // MARK: - Properties
    public let id: UUID?
    public let planets: [Planet]
    
    // MARK: - Initializer
    public init(
        id: UUID?,
        planets: [Planet]
    ) {
        self.id = id
        self.planets = planets
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(planets, forKey: .planets)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        planets = try container.decode([Planet].self, forKey: .planets)
    }
}
