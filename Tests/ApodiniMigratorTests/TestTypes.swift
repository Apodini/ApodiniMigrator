//
//  File.swift
//  
//
//  Created by Eldi Cano on 16.08.21.
//

import Foundation

enum TestTypes {}

extension TestTypes {
    struct Student: Codable {
        let id: UUID
        let name: String
        let friends: [String]
        let age: Int
        let grades: [Double: String]
        let birthday: Date
        let url: URL?
        let shop: Shop
        let car: Car
    }
    
    enum Direction: String, Codable {
        case left
        case right
    }
    
    struct Car: Codable {
        let plateNumber: Int
        let name: String
    }
    
    struct SomeStudent: Codable {
        let id: UUID
        let exams: [Date]
    }
    
    struct Shop: Codable {
        let id: UUID
        let licence: UInt?
        let url: URL
        let directions: [UUID: Direction]
        let car: Car
    }
    
    struct SomeStruct: Codable {
        let someDictionary: [URL: Shop]
    }
    
    struct User: Codable {
        let student: [Int: SomeStudent??]
        let birthday: [Date]
        let url: URL
        let scores: [Set<Int>]
        let name: String?
        // swiftlint:disable:next discouraged_optional_collection
        let nestedDirections: Set<[[[[[Direction]?]?]?]]> /// testing recursive storing and reconstructing in `TypesStore`
        let shops: [Shop]
        let cars: [String: Car]
        let otherCars: [Car]
    }
    
}
