//
//  File.swift
//  
//
//  Created by Eldi Cano on 01.06.21.
//

//import Foundation
//import FluentKit
//
//
//final class PlanetTag: Model {
//    static let schema = "planet+tag"
//
//    @ID(key: .id)
//    var id: UUID?
//
//    @Parent(key: "planet_id")
//    var planet: Planet
//
//    @Parent(key: "tag_id")
//    var tag: Tag
//
//    init() { }
//
//    init(id: UUID? = nil, planet: Planet, tag: Tag) throws {
//        self.id = id
//        self.$planet.id = try planet.requireID()
//        self.$tag.id = try tag.requireID()
//    }
//}
//
//final class Planet: Model {
//    static let schema = "planet"
//    @ID(key: .id)
//    var id: UUID?
//    
//    init() { }
//    
//    // Example of a siblings relation.
//    @Siblings(through: PlanetTag.self, from: \.$planet, to: \.$tag)
//    public var tags: [Tag]
//}
//
//final class Tag: Model {
//    static let schema = "tag"
//    @ID(key: .id)
//    var id: UUID?
//    
//    init() { }
//    @Siblings(through: PlanetTag.self, from: \.$tag, to: \.$planet)
//    public var planets: [Planet]
//}
//
//public final class UsersBooks: Model {
//    public static let schema = "usersbook"
//    
//    @ID
//    public var id: UUID?
//    
//    @Parent(key: "user_id")
//    public var user: User
//    
//    @Parent(key: "book_id")
//    public var book: Book
//    
//    public init() {}
//    
//    public init(userID: UUID, bookID: UUID) {
//        self.$book.id = bookID
//        self.$user.id = userID
//    }
//}
//
//public final class User: Model {
//    public static let schema = "users"
//    
//    @ID
//    public var id: UUID?
//    
//    @Field(key: "email")
//    public var email: String
//    
//    @Field(key: "password_hash")
//    public var passwordHash: String
//    
//    @Siblings(through: UsersBooks.self, from: \.$user, to: \.$book)
//    public var books: [Book]
//    
//    public init() { }
//    
//    public init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
//        self.id = id
//        self.email = email
//        self.passwordHash = passwordHash
//    }
//}
//
//public final class Book: Model {
//    public static let schema = "books"
//    
//    @ID
//    public var id: UUID?
//    
//    @Field(key: "title")
//    public var title: String
//    
//    @Siblings(through: UsersBooks.self, from: \.$book, to: \.$user)
//    public var owners: [User]
//    
//    public init() {}
//    
//    public init(id: UUID? = nil, title: String) {
//        self.id = id
//        self.title = title
//    }
//}
