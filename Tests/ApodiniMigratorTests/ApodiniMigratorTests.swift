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
    
    struct Shop: Codable {
        let id: UUID
        let licence: UInt
        let isOpen: Bool
        let directions: [Direction]
    }
    
    struct User: Codable {
        let birthday: Date
        let scores: [Int]
        let name: String
        let shops: [Shop]
        let cars: [String: Car]
    }
    
    func testExample() throws {
        guard !isLinux() else { return }
        
        XCTAssertNoThrow(try TypeContainer(type: User.self))
    }
}
