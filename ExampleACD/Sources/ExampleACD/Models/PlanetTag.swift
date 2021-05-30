//
//  PlanetTag.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public final class PlanetTag: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case planet = "planet"
        case tag = "tag"
    }
    
    // MARK: - Properties
    public let id: UUID?
    public let planet: Planet
    public let tag: Tag
    
    // MARK: - Initializer
    public init(
        id: UUID?,
        planet: Planet,
        tag: Tag
    ) {
        self.id = id
        self.planet = planet
        self.tag = tag
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(planet, forKey: .planet)
        try container.encode(tag, forKey: .tag)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        planet = try container.decode(Planet.self, forKey: .planet)
        tag = try container.decode(Tag.self, forKey: .tag)
    }
}
