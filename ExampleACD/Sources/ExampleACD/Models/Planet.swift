//
//  Planet.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public final class Planet: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case tags = "tags"
    }
    
    // MARK: - Properties
    public let id: UUID?
    public let tags: [Tag]
    
    // MARK: - Initializer
    public init(
        id: UUID?,
        tags: [Tag]
    ) {
        self.id = id
        self.tags = tags
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        tags = try container.decode([Tag].self, forKey: .tags)
    }
}
