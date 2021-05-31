//
//  Contact.swift
//
//  Created by ApodiniMigrator on 31.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public struct Contact: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case birthday = "birthday"
        case id = "id"
        case name = "name"
    }
    
    // MARK: - Properties
    public let birthday: Date
    public let id: UUID?
    public let name: String
    
    // MARK: - Initializer
    public init(
        birthday: Date,
        id: UUID?,
        name: String
    ) {
        self.birthday = birthday
        self.id = id
        self.name = name
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(birthday, forKey: .birthday)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        birthday = try container.decode(Date.self, forKey: .birthday)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}
