//
//  Greeting.swift
//
//  Created by ApodiniMigrator on 14.11.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public struct Greeting: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case greet
    }
    
    // MARK: - Properties
    public var greet: String
    
    // MARK: - Initializer
    public init(
        greet: String
    ) {
        self.greet = greet
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(greet, forKey: .greet)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        greet = try container.decode(String.self, forKey: .greet)
    }
}
