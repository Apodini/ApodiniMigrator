import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorClientSupport
@testable import ApodiniMigratorGenerator
@testable import ApodiniMigratorCompare
@testable import Runtime

extension ApodiniMigratorCodable {
    static var encoder: JSONEncoder {
        .init()
    }
    static var decoder: JSONDecoder {
        .init()
    }
}

let skipFileReadingTests = true

typealias Codable = ApodiniMigratorCodable

final class JavaScriptConvertTests: ApodiniMigratorXCTestCase {
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
    
    struct Student: Codable, Equatable {
        let name: String
        let matrNr: UUID
        let dog: Dog
        let number: Int
    }
    
    struct Dog: Codable, Equatable {
        let name: String
    }
    
    
    func testMultipleArguments() throws {
        let constructScript =
        """
        function convert(name, matrNr, dog) {
            let parsedName = JSON.parse(name)
            let parsedMatrNr = JSON.parse(matrNr)
            let parsedDog = JSON.parse(dog)
            return JSON.stringify({ 'name' : parsedName, 'matrNr' : parsedMatrNr, 'dog' : parsedDog, 'number': 42 })
        }
        """
        
        let student = try Student.fromValues("John", UUID(), Dog(name: "Dog"), script: constructScript)
        
        
        XCTAssert(student.dog.name == "Dog")
        XCTAssert(student.name == "John")
        XCTAssert(student.number == 42)
    }
    
    func testMalformedInputAndScript() throws {
        struct Student: Codable, Equatable {
            let name: String
            let github: URL
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
        
        // swiftlint:disable:next discouraged_optional_collection
        let someInstance: [String???]? = []
        
        // input is wrong, and the script is invalid, the default empty instance is created
        let student = try Student.from(someInstance, script: constructScript)
        
        XCTAssert(student.name == .default)
        XCTAssert(student.github == .default)
    }
    
    func testPackageGenerator() throws {
        let packagePath: Path = .desktop
        guard packagePath.exists, !skipFileReadingTests else {
            return
        }
        
        let document = Path.desktop + "delta_document.json"
        
        let gen = try ApodiniMigratorGenerator(packageName: "ExampleACD", packagePath: packagePath.string, documentPath: document.string)
        XCTAssertNoThrow(try gen.build())
    }
    
    func testPackageFilesCollector() throws {
        guard Path.desktop.exists, !skipFileReadingTests else {
            return
        }
        
        let packageFilesCollector = PackageFilesCollector(packageName: "ExampleACD", packagePath: .desktop)
        
        let user = packageFilesCollector.model(name: "Contact")
        
        var objectFileParser = try ObjectFileParser(path: user)
        
        let endpoint = packageFilesCollector.endpoint(name: "Contact")
        
        let fileParser = try EndpointFileParser(path: endpoint)
        try fileParser.save()
        objectFileParser.addCodingKeyCase(name: "someTest")
        try objectFileParser.save()
    }
    
    func testMigraionGuideGeneration() throws {
        guard Path.desktop.exists, !skipFileReadingTests else {
            return
        }
        
        let doc = Path.desktop + "document.json"
        let doc2 = Path.desktop + "document_updated.json"
        
        let document1 = try Document.decode(from: doc)
        let document2 = try Document.decode(from: doc2)
        
        let migrationGuide = MigrationGuide(for: document1, rhs: document2)
        try (Path.desktop + "migration_guide.json").write(migrationGuide.json)
    }
    
    func testEndpointPath() throws {
        let string = "/v1/{some}/users/{id}"
        let string1 = "/v1/{s}/users/{idsdad}"
        let string2 = "/v2/{s}/users/{idsdad}" // still considered equal, change is delegated to networking due to version change
  
        XCTAssert(EndpointPath(string) == EndpointPath(string1))
        XCTAssert(EndpointPath(string1) == EndpointPath(string2))
    }
    
    func testMultipleContentParameters() {
        let param1 = Parameter(parameterName: "one", typeInformation: .scalar(.string), hasDefaultValue: false, parameterType: .content)
        let param2 = Parameter(parameterName: "two", typeInformation: .scalar(.string), hasDefaultValue: false, parameterType: .content)
        let endpoint = Endpoint(handlerName: "Handler", deltaIdentifier: "helloHandler", operation: .create, absolutePath: "/hello", parameters: [param1, param2], response: .scalar(.string), errors: [])
        
        
        let parameters = endpoint.parameters
        let first = parameters.first
        XCTAssertTrue(parameters.count == 1)
        XCTAssertTrue(first?.name == Parameter.wrappedContentParameter)
        XCTAssertTrue(first?.hasDefaultValue == false)
    }
}
