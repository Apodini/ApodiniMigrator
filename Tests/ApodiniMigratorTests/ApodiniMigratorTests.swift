import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorGenerator
@testable import ApodiniMigratorClientSupport

func isLinux() -> Bool {
    #if os(Linux)
    return true
    #else
    return false
    #endif
}

final class ApodiniMigratorTests: ApodiniMigratorXCTestCase {
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
        let testClass: ApodiniMigratorTests /// non-codable properties are ignored from initializer of `TypeInformation`
        
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
        
        let typeInformation = try TypeInformation(type: someComplexType.self)
        
        var store = TypesStore()
        
        let reference = store.store(typeInformation) /// storing and retrieving a reference

        let result = store.construct(from: reference) /// reconstructing type from the reference
        
        XCTAssertEqual(result, typeInformation)
    }
    
    
    func testJSONStringBuilder() throws {
        guard !isLinux() else {
            return
        }
        
        let typeInformation = try TypeInformation(type: someComplexType)
        let instance = XCTAssertNoThrowWithResult(try JSONStringBuilder.instance(typeInformation, someComplexType))
        
        XCTAssert(instance.keys.first == 0)
        // swiftlint:disable:next force_unwrapping
        let userInstance = instance.values.first!.values.first!!!!!!
        XCTAssert(userInstance.birthday.first?.noon == .today)
        XCTAssert(userInstance.url == .defaultURL)
    }
    
    func testFileGenerator() throws {
        guard !isLinux(), isEldisMacbook() else {
            return
        }
        
        let desktop = Path.desktop
        let student = XCTAssertNoThrowWithResult(try TypeInformation(type: Student.self))
        let absolutePath = XCTAssertNoThrowWithResult(try ObjectFileTemplate(student).write(at: desktop))
        XCTAssertTrue(absolutePath.exists)
    }
    
    struct Student: Codable {
        let id: UUID
        let name: String
        let friends: [String]
        let age: Int
        let grades: [Double]
        let birthday: Date
        let url: URL
        let shop: Shop
        let car: Car
    }
    
    let jsonPath: Path = .desktop + "\(Student.self).json"
    
    func testJSONCreation() throws {
        guard !isLinux(), isEldisMacbook() else {
            return
        }
        try jsonPath.write(try JSONStringBuilder.string(Student.self))
    }
    
    func testJSONRead() throws {
        guard !isLinux(), isEldisMacbook() else {
            return
        }
        _ = XCTAssertNoThrowWithResult(try JSONStringBuilder.decode(Student.self, at: jsonPath))
    }
    
    
    let testModels: Path = .desktop + "TestModels"
    
    func generateTestModels() throws {
        guard !isLinux(), testModels.exists else {
            return
        }
        let types: [Any.Type] = [
            User.self,
            Student.self
        ]
        
        try RecursiveFileGenerator(types).persist(at: testModels)
    }
    
    func testEnumFileUpdate() throws {
        guard isEldisMacbook() else {
            return
        }
        try generateTestModels()
        
        var enumFileParser = try EnumFileParser(path: testModels + "Direction.swift")
        
        enumFileParser.rename(case: "left", to: "links")
        enumFileParser.deleted(case: "right")
        try enumFileParser.save()
    }
    
    func testObjectFileUpdate() throws {
        guard isEldisMacbook() else {
            return
        }
        try generateTestModels()
        
        var objectFileParser = try ObjectFileParser(path: testModels + "Student.swift")
        
        objectFileParser.renamed(property: "id", to: "identifier")
        objectFileParser.addCodingKeyCase(name: "githubProfile")
        objectFileParser.changedType(of: "name")
        
        try objectFileParser.save()
    }
}
