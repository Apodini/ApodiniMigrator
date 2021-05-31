/*
import FluentKit
import Foundation


enum Direction: String, Codable {
    case left
    case right
}

// MARK: Contact
public final class Contact: Model {
    public static let schema = "contacts"
    
    
    @ID
    public var id: UUID?
    
    @Timestamp(key: "createdAt", on: .create)
    public var createdAt: Date?
    
    @Field(key: "name2")
    public var name: String
    
    @OptionalEnum(key: "key")
    var direction: Direction?
    
    @Field(key: "birthday")
    public var birthday: Date?
    
    @Children(for: \.$contact)
    public var residencies: [Residence]
    
    @OptionalChild(for: \.$cont)
    public var ch: Residence?
    
    let contact: Contact = .init()
    
    public init() { }
    
    public init(id: UUID? = nil, name: String, birthday: Date) {
        self.id = id
        self.name = name
        self.birthday = birthday
    }
}

// MARK: Contact: Equatable
extension Contact: Equatable {
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Contact: Comparable
extension Contact: Comparable {
    public static func < (lhs: Contact, rhs: Contact) -> Bool {
        lhs.name < rhs.name
    }
}

// MARK: Contact: Hashable
extension Contact: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class PlanetTag: Model {
    static let schema = "planet+tag"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "planet_id")
    var planet: Planet

    @Parent(key: "tag_id")
    var tag: Tag

    init() { }

    init(id: UUID? = nil, planet: Planet, tag: Tag) throws {
        self.id = id
        self.$planet.id = try planet.requireID()
        self.$tag.id = try tag.requireID()
    }
}

final class Planet: Model {
    static let schema = "planet"
    @ID(key: .id)
    var id: UUID?
    
    init() { }
    
    // Example of a siblings relation.
    @Siblings(through: PlanetTag.self, from: \.$planet, to: \.$tag)
    public var tags: [Tag]
}

final class Tag: Model {
    static let schema = "tag"
    @ID(key: .id)
    var id: UUID?
    
    init() { }
    @Siblings(through: PlanetTag.self, from: \.$tag, to: \.$planet)
    public var planets: [Planet]
}

// MARK: Residence
public final class Residence: Model {
    public static let schema = "residencies"
    
    
    @ID
    public var id: UUID?
    
    @Timestamp(key: "createdAt", on: .create)
    public var createdAt: Date?
    
    @Field(key: "address")
    public var address: String
    
    @Field(key: "postalCode")
    public var postalCode: String
    
    @Field(key: "country")
    public var country: String
    
    @Parent(key: "contact_id")
    public var contact: Contact
    
    @OptionalParent(key: "contact_id")
    public var cont: Contact?
    
    public init() { }
    
    public init(id: UUID? = nil, address: String, postalCode: String, country: String, contact: Contact.IDValue) {
        self.id = id
        self.address = address
        self.postalCode = postalCode
        self.country = country
        self.$contact.id = contact
    }
}

// MARK: Residence: Equatable
extension Residence: Equatable {
    public static func == (lhs: Residence, rhs: Residence) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: Residence: Comparable
extension Residence: Comparable {
    public static func < (lhs: Residence, rhs: Residence) -> Bool {
        lhs.country < rhs.country
    }
}

// MARK: Residence: Hashable
extension Residence: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
*/
