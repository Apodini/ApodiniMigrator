//
//  Residence.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Model
public final class Residence: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case address = "address"
        case contact = "contact"
        case country = "country"
        case createdAt = "createdAt"
        case id = "id"
        case postalCode = "postalCode"
    }
    
    // MARK: - Properties
    public let address: String
    public let contact: Contact
    public let country: String
    public let createdAt: Date?
    public let id: UUID?
    public let postalCode: String
    
    // MARK: - Initializer
    public init(
        address: String,
        contact: Contact,
        country: String,
        createdAt: Date?,
        id: UUID?,
        postalCode: String
    ) {
        self.address = address
        self.contact = contact
        self.country = country
        self.createdAt = createdAt
        self.id = id
        self.postalCode = postalCode
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(address, forKey: .address)
        try container.encode(contact, forKey: .contact)
        try container.encode(country, forKey: .country)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(id, forKey: .id)
        try container.encode(postalCode, forKey: .postalCode)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(String.self, forKey: .address)
        contact = try container.decode(Contact.self, forKey: .contact)
        country = try container.decode(String.self, forKey: .country)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        postalCode = try container.decode(String.self, forKey: .postalCode)
    }
}
