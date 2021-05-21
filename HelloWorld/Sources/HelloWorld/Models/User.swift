//
//  User.swift
//
//  Created by ApodiniMigrator on 21.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
struct User: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case writtenId = "writtenId"
    }
    
    // MARK: - Properties
    let id: Int
    let writtenId: UUID
    
    // MARK: - Initializer
    init(
        id: Int,
        writtenId: UUID
    ) {
        self.id = id
        self.writtenId = writtenId
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(writtenId, forKey: .writtenId)
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        writtenId = try container.decode(UUID.self, forKey: .writtenId)
    }
}
