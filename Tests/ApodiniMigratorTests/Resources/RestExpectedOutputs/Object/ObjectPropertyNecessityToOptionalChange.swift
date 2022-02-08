//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public struct User: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case age
        case friends
        case githubProfile
        case id
        case isStudent
        case name
    }
    
    // MARK: - Properties
    public var age: UInt?
    public var friends: [UUID]
    public var githubProfile: URL
    public var id: UUID
    public var isStudent: String
    public var name: String
    
    // MARK: - Initializer
    public init(
        age: UInt?,
        friends: [UUID],
        githubProfile: URL,
        id: UUID,
        isStudent: String,
        name: String
    ) {
        self.age = age
        self.friends = friends
        self.githubProfile = githubProfile
        self.id = id
        self.isStudent = isStudent
        self.name = name
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(age, forKey: .age)
        try container.encode(friends, forKey: .friends)
        try container.encode(githubProfile, forKey: .githubProfile)
        try container.encode(id, forKey: .id)
        try container.encode(isStudent, forKey: .isStudent)
        try container.encode(name, forKey: .name)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        age = try container.decodeIfPresent(UInt.self, forKey: .age)
        friends = try container.decode([UUID].self, forKey: .friends)
        githubProfile = try container.decode(URL.self, forKey: .githubProfile)
        id = try container.decode(UUID.self, forKey: .id)
        isStudent = try container.decode(String.self, forKey: .isStudent)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? (try String.instance(from: 4))
    }
}
