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
        let typeContainer = try TypeContainer(type: User.self)
        
        print(typeContainer.json)

        let instance = try JSONStringBuilder.instance(typeContainer, User.self)

        XCTAssertTrue(instance.scores.first == 0)
        XCTAssertTrue(instance.birthday == .test)
        XCTAssertTrue(instance.shops.first?.id == .test)
    }
    
    static var allTests = [
        ("testExample", testExample)
    ]
}
