//
//  PostResponse.swift
//
//  Created by ApodiniMigrator on 21.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
struct PostResponse: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case _links = "_links"
        case data = "data"
    }
    
    // MARK: - Properties
    let _links: [String: String]
    let data: Post
    
    // MARK: - Initializer
    init(
        _links: [String: String],
        data: Post
    ) {
        self._links = _links
        self.data = data
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_links, forKey: ._links)
        try container.encode(data, forKey: .data)
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _links = try container.decode([String: String].self, forKey: ._links)
        data = try container.decode(Post.self, forKey: .data)
    }
}
