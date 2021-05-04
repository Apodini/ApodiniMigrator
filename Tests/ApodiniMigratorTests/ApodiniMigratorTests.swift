import XCTest
@testable import ApodiniMigrator

func isLinux() -> Bool {
    #if os(Linux)
    return true
    #else
    return false
    #endif
}

final class ApodiniMigratorTests: XCTestCase {
    enum Direction: String, Codable {
        case left
        case right
    }
    
    struct Car: Codable {
        let plateNumber: Int
        let name: String
    }
    
    struct Student: Codable {
        let ids: [Date]
        let name: String
    }
    
    struct Shop: Codable {
        let id: UUID
        let licence: UInt?
        let isOpen: Bool
        let directions: [UUID: Direction]
    }
    
    struct SomeThingElse: Codable {
        let somesoem: [Bool: Shop]
    }
    
    struct User: Codable {
        let student: Student?
        let birthday: [Date: SomeThingElse]
        let scores: [Int]
        let name: String?
        let shops: [Shop]
        let cars: [String: Car]
        let otherCar: [Car]
    }
    
    func testExample() throws {
        guard !isLinux() else { return }
        
        let typeDescriptor = try TypeDescriptor(type: User.self)
        
        var store = TypesStore()
        
        let reference = store.store(typeDescriptor)

        
        let result = store.construct(from: reference)
        
//        let references = result.filter(\.isReference)
        
        print(store.json)
        
//        let allKeys = store.types.keys
//        print(allKeys)
//        print(result.json)
        
        XCTAssertEqual(result, typeDescriptor)
    }
}
