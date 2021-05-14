import XCTest
@testable import ApodiniMigrator

final class JavaScriptConvertTests: XCTestCase {
    
    func testDecodableExample() throws {
        struct Student: Codable, Equatable {
            let name: String
            let matrNr: UUID
        }
        
        struct Developer: Codable, Equatable {
            let id: UUID
            let name: String
        }
        
        let student = Student(name: "John", matrNr: UUID())
        let studentToDeveloperScript =
        """
        function convert(object) {
            let parsed = JSON.parse(object)
            return JSON.stringify({ 'id' : parsed.matrNr, 'name' : parsed.name })
        }
        """
        let developer = try Developer.from(student, script: studentToDeveloperScript)
        
        let developerToStudentScript =
        """
        function convert(object) {
            let parsed = JSON.parse(object)
            return JSON.stringify({ 'matrNr' : parsed.id, 'name' : parsed.name })
        }
        """
        
        let initialStudent = try Student.from(developer, script: developerToStudentScript)
        XCTAssert(developer.id == student.matrNr)
        XCTAssert(developer.name == student.name)
        
        XCTAssert(student == initialStudent)
    }
    
    func testMultipleArguments() throws {
        struct Student: Codable, Equatable {
            let name: String
            let matrNr: UUID
            let dog: Dog
        }
        
        struct Dog: Codable, Equatable {
            let name: String
        }
        
        let constructScript =
        """
        function convert(name, matrNr, dog) {
            let parsedName = JSON.parse(name)
            let parsedMatrNr = JSON.parse(matrNr)
            let parsedDog = JSON.parse(dog)
            return JSON.stringify({ 'name' : parsedName.value, 'matrNr' : parsedMatrNr.value, 'dog' : parsedDog.value })
        }
        """
        
        let student = try Student.fromValues(.init("John"), .init(UUID()), .init(Dog(name: "Dog")), script: constructScript)
        
        
        XCTAssert(student.dog.name == "Dog")
        XCTAssert(student.name == "John")
    }
    
    func testMalformedInputAndScript() throws {
        struct Student: Codable, Equatable {
            let name: String
            let matrNr: UUID
            let dog: Dog
        }
        
        struct Dog: Codable, Equatable {
            let name: String
        }
        
        let constructScript =
        """
        function convert(name, matrNr, dog) {
            return JSON object { name, s, dog with name dog }
        }
        """
        
        // input is wrong, and the script is invalid, the default empty instance is created
        let student = try Student.from(5, script: constructScript)
        
        XCTAssert(student.name == "")
        XCTAssert(student.matrNr == .defaultUUID)
    }
}
