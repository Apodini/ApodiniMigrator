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
    
    struct SomeStruct: Codable {
        let someDictionary: [Bool: Shop]
    }
    
    struct User: Codable {
        let student: [Int: Student??]
        let birthday: [Date]
        let scores: [Int]
        let name: String?
        let nestedDirections: [[[[[Direction]]]]]
        let shops: [Shop]
        let cars: [String: Car]
        let otherCar: [Car]
    }
    
    let someComplexType = [Int: [UUID: User?????]].self
    
    func testTypeStore() throws {
        guard !isLinux() else { return }
        
        let typeDescriptor = try TypeDescriptor(type: someComplexType.self)
        
        var store = TypesStore()
        
        let reference = store.store(typeDescriptor) /// storing and retrieving a reference

        let result = store.construct(from: reference) /// reconstructing type from the reference
        
        XCTAssertEqual(result, typeDescriptor)
    }
    
    
    func testJSONStringBuilder() throws {
        guard !isLinux() else { return }
        
        let typeDescriptor = try TypeDescriptor(type: someComplexType)
        let instance = XCTAssertNoThrowWithResult(try JSONStringBuilder.instance(typeDescriptor, someComplexType))
        
        XCTAssert(instance.keys.first == 0)
        // swiftlint:disable:next force_unwrapping
        let userInstance = instance.values.first!.values.first!!!!!!
        XCTAssert(userInstance.birthday.first == .today)
        XCTAssert(userInstance.shops.first?.id == .defaultUUID)
    }
    
    
    func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        
        do {
            return try expression()
        } catch {
            XCTFail(error.localizedDescription)
        }
        fatalError("Expression threw an error")
    }
}
