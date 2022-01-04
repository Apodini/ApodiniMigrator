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
        case githubProfile = "githubURL"
        case id
        case isStudent
        case name
        case username
    }
    
    // MARK: - Properties
    public var age: UInt?
    public var friends: [UUID]
    public var githubProfile: URL
    public var id: UUID
    public var isStudent: String
    public var name: String
    public var username: String
    
    // MARK: - Initializer
    public init(
        age: UInt?,
        friends: [UUID],
        githubProfile: URL,
        id: UUID,
        isStudent: String,
        name: String,
        username: String = try! String.instance(from: 1)
    ) {
        self.age = age
        self.friends = friends
        self.githubProfile = githubProfile
        self.id = id
        self.isStudent = isStudent
        self.name = name
        self.username = username
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(age ?? (try UInt.instance(from: 3)), forKey: .age)
        try container.encode(githubProfile, forKey: .githubProfile)
        try container.encode(id, forKey: .id)
        try container.encode(try Bool.from(isStudent, script: 1), forKey: .isStudent)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        age = try container.decodeIfPresent(UInt.self, forKey: .age)
        friends = try [UUID].instance(from: 2)
        githubProfile = try container.decode(URL.self, forKey: .githubProfile)
        id = try container.decode(UUID.self, forKey: .id)
        isStudent = try String.from(try container.decode(Bool.self, forKey: .isStudent), script: 2)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? (try String.instance(from: 4))
        username = try container.decode(String.self, forKey: .username)
    }
}
