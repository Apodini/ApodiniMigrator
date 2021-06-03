///*
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

final class Pet: Fields {
    @Field(key: "name")
    var name: String

    init() { }

    init(name: String) {
        self.name = name
    }
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
    
    @Group(key: "")
    var pet: Pet
//    
//    @OptionalParent(key: "contact_id")
//    public var cont: Contact?
    
    public init() { }
    
    public init(id: UUID? = nil, address: String, postalCode: String, country: String, contact: Contact.IDValue) {
        self.id = id
        self.address = address
        self.postalCode = postalCode
        self.country = country
        self.$contact.id = contact
        self.pet = .init(name: "")
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
//*/
