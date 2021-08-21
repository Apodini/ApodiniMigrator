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
    
    enum Direction: String, Codable, Hashable {
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
        let directions: [UUID: Int]
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
        let nestedDirections: Set<[[[[[Direction]?]?]?]]> // testing recursive storing and reconstructing in `TypesStore`
        let shops: [Shop]
        let cars: [String: Car]
        let otherCars: [Car]
    }
    
    struct Generic<V1, V2> {
        let value1: V1
        let value2: V2
    }
}
