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
    
    struct SomeStudent: Codable {
        // MARK: Private Inner Types
        private enum CodingKeys: String, CodingKey {
            case exams
        }
        let exams: [Date]
        let testClass: ApodiniMigratorTests /// non-codable properties are ignored from initializer of `TypeDescriptor`
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(exams, forKey: .exams)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            exams = try container.decode([Date].self, forKey: .exams)
            testClass = .init()
        }
    }
    
    struct Shop: Codable {
        let id: UUID
        let licence: UInt?
        let url: URL
        let directions: [UUID: Direction]
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
    
    let someComplexType = [Int: [UUID: User?????]].self
    
    /// testing recursive storing and reconstructing in `TypesStore`
    func testTypeStore() throws {
        guard !isLinux() else {
            return
        }
        
        let typeDescriptor = try TypeDescriptor(type: someComplexType.self)
        
        var store = TypesStore()
        
        let reference = store.store(typeDescriptor) /// storing and retrieving a reference

        let result = store.construct(from: reference) /// reconstructing type from the reference
        
        XCTAssertEqual(result, typeDescriptor)
    }
    
    
    func testJSONStringBuilder() throws {
        guard !isLinux() else {
            return
        }
        
        let typeDescriptor = try TypeDescriptor(type: someComplexType)
        let instance = XCTAssertNoThrowWithResult(try JSONStringBuilder.instance(typeDescriptor, someComplexType))
        
        XCTAssert(instance.keys.first == 0)
        // swiftlint:disable:next force_unwrapping
        let userInstance = instance.values.first!.values.first!!!!!!
        XCTAssert(userInstance.birthday.first == .today)
        XCTAssert(userInstance.shops.first?.id == .defaultUUID)
        XCTAssert(userInstance.url == .defaultURL)
    }
    
    
    func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        
        do {
            return try expression()
        } catch {
            XCTFail(error.localizedDescription)
        }
        preconditionFailure("Expression threw an error")
    }
    
    func testFileGenerator() throws {
        let desktop = Path.desktop
        guard !isLinux(), desktop.exists else {
            return
        }
        
        struct Student {
            let id: UUID
            let name: String
            let friendsNames: [String]
            let age: Int
            let grades: [Double]
            let birthday: Date
            let url: URL
        }
        
        let student = XCTAssertNoThrowWithResult(try TypeDescriptor(type: Student.self))
        let absolutePath = XCTAssertNoThrowWithResult(try ObjectFileTemplate(student).write(at: desktop))
        XCTAssertTrue(absolutePath.exists)
    }
}
