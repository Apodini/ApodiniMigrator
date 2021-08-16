import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare
@testable import ApodiniMigratorClientSupport
@testable import Runtime

final class InstanceCreatorTests: ApodiniMigratorXCTestCase {
    func testNoAssociatedValuesforEnumAllowed() throws {
        XCTAssertThrowsError(try TypeInformation.of(TypeInformation.self, with: RuntimeBuilder.self))
    }
    
    struct Student: Codable, Equatable {
        let name: String
        let matrNr: UUID
        let dog: Dog
    }
    
    struct Dog: Codable, Equatable {
        let name: String
    }
    
    func testCardinality() {
        let dictionaryCardinality = Cardinality.dictionary(key: String.self, value: Student.self)
        
        XCTAssertEqual(dictionaryCardinality, .dictionary(key: String.self, value: Student.self))
        
        XCTAssertNotEqual(dictionaryCardinality, .exactlyOne(Student.self))
        
        XCTAssertNotEqual(Cardinality.optional(Student.self), .exactlyOne(Student.self))
        
        
        XCTAssertEqual(try cardinality(of: Student.self), .exactlyOne(Student.self))
        XCTAssertEqual(try cardinality(of: Student?.self), .optional(Student.self))
        XCTAssertEqual(try cardinality(of: [[Student]].self), .repeated([Student].self))
        XCTAssertEqual(try cardinality(of: [Int: Student].self), .dictionary(key: Int.self, value: Student.self))
    }
    
    func testNonFluentModel() throws {
        let student = try typedInstance(Student.self)
        
        let studentJSON = student.json
        
        let studentFromJSON = try Student.decode(from: studentJSON)
        XCTAssert(student == studentFromJSON)
    }
    
    /// `InstanceCreator` excplicitly checks for property wrappers, and sets the value
    /// Working example
    @propertyWrapper
    struct EncodableContainer<Element: Encodable>: Encodable {
        var wrappedValue: Element
    }

    struct SomeStruct: Encodable {
        @EncodableContainer
        var number: Int
    }
    
    func testSettingValueOnPropertyWrapper() throws {
        let testValue = 42
        
        InstanceCreator.testValue = testValue
        let someStructInstance = try typedInstance(SomeStruct.self)
        XCTAssert(someStructInstance.number == testValue)
        
        InstanceCreator.testValue = nil
    }
    
    func testTypeInformationWithPropertyWrapper() throws {
        let typeInformation = try TypeInformation(type: SomeStruct.self)
        
        XCTAssertTrue(typeInformation.objectProperties.first?.annotation == "@EncodableContainer")
    }
}
