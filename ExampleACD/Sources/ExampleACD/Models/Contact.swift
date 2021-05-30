//
//  Contact.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public final class Contact: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case birthday = "birthday"
        case createdAt = "createdAt"
        case direction = "direction"
        case id = "id"
        case name = "name"
        case residencies = "residencies"
    }
    
    // MARK: - Properties
    public let birthday: Date
    public let createdAt: Date?
    public let direction: Direction?
    public let id: UUID?
    public let name: String
    public let residencies: [Residence]
    
    // MARK: - Initializer
    public init(
        birthday: Date,
        createdAt: Date?,
        direction: Direction?,
        id: UUID?,
        name: String,
        residencies: [Residence]
    ) {
        self.birthday = birthday
        self.createdAt = createdAt
        self.direction = direction
        self.id = id
        self.name = name
        self.residencies = residencies
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(birthday, forKey: .birthday)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(direction, forKey: .direction)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(residencies, forKey: .residencies)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        birthday = try container.decode(Date.self, forKey: .birthday)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        direction = try container.decodeIfPresent(Direction.self, forKey: .direction)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        residencies = try container.decode([Residence].self, forKey: .residencies)
    }
}
