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
    func testExample() throws {
        guard !isLinux() else { return }
        
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
            let cars: [String: Shop]
        }
        
        
        XCTAssertNoThrow(try TypeContainer(type: User.self))
        
        let instance = XCTAssertNoThrowWithReturn(try JSONStringBuilder.instance(User.self))
        
        XCTAssertTrue(instance.scores.first == 0)
        XCTAssertTrue(instance.birthday == .test)
        XCTAssertTrue(instance.shops.first?.id == .test)
    }
    
    
    func XCTAssertNoThrowWithReturn<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        do {
            return try expression()
        } catch {
            XCTFail(error.localizedDescription)
        }
        fatalError("Expression throw an error")
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
