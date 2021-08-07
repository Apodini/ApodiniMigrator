import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport
@testable import ApodiniMigrator
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


extension Date: Codable {
    public static var encoder: JSONEncoder {
        .init()
    }
    public static var decoder: JSONDecoder {
        .init()
    }
}

extension Data: Codable {
    public static var encoder: JSONEncoder {
        .init()
    }
    public static var decoder: JSONDecoder {
        .init()
    }
}


let skipFileReadingTests = false

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
        let developer = try Developer.from(student, script: JSScript(studentToDeveloperScript))
        
        let developerToStudentScript =
        """
        function convert(object) {
            let parsed = JSON.parse(object)
            return JSON.stringify({ 'matrNr' : parsed.id, 'name' : parsed.name })
        }
        """
        
        let initialStudent = try Student.from(developer, script: JSScript(developerToStudentScript))
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
        
        let student = try Student.fromValues("John", UUID(), Dog(name: "Dog"), script: JSScript(constructScript))
        
        
        XCTAssert(student.dog.name == "Dog")
        XCTAssert(student.name == "John")
        XCTAssert(student.number == 42)
    }
    
    func testEndpointPath() throws {
        let string = "/v1/{some}/users/{id}"
        let string1 = "/v1/{s}/users/{idsdad}"
        let string2 = "/v2/{s}/users/{idsdad}" // still considered equal, change is delegated to networking due to version change
  
        XCTAssert(EndpointPath(string) != EndpointPath(string1))
        XCTAssert(EndpointPath(string1) == EndpointPath(string2))
    }
    
    func testMultipleContentParameters() {
        let param1 = Parameter(name: "one", typeInformation: .scalar(.string), parameterType: .content, isRequired: false)
        let param2 = Parameter(name: "two", typeInformation: .scalar(.string), parameterType: .content, isRequired: false)
        let endpoint = Endpoint(handlerName: "Handler", deltaIdentifier: "helloHandler", operation: .create, absolutePath: "/hello", parameters: [param1, param2], response: .scalar(.string), errors: [])
        
        
        let parameters = endpoint.parameters
        let first = parameters.first
        XCTAssertTrue(parameters.count == 1)
        XCTAssertTrue(first?.name == Parameter.wrappedContentParameter)
        XCTAssertTrue(first?.necessity == .optional)
    }
    
    func testIntString() throws {
        let script = JSPrimitiveScript.stringNumber
        
        let number = try Int.from("123123", script: script.convertFromTo)
        let string = try String.from(number, script: script.convertToFrom)
        let zero = try Int.from("helloWorld", script: script.convertFromTo)
        XCTAssertEqual(number, 123123)
        XCTAssertEqual(string, "123123")
        XCTAssertEqual(zero, 0)
    }
    
    func testFloatString() throws {
        let script = JSPrimitiveScript.stringFloat
        
        let number = try Double.from("123123.2", script: script.convertFromTo)
        let string = try String.from(number, script: script.convertToFrom)
        let zero = try Float.from("helloWorld", script: script.convertFromTo)
        XCTAssertEqual(number, 123123.2)
        XCTAssertEqual(string, "123123.2")
        XCTAssertEqual(zero, 0)
    }
    
    func testNumberUnsigned() throws {
        let script = JSPrimitiveScript.numberUnsignedNumber
        
        let number = try Int.from(123123123, script: script.convertFromTo)
        let uint = try UInt64.from(number, script: script.convertToFrom)
        let zero = try UInt64.from(-123123, script: script.convertFromTo)
        XCTAssertEqual(number, 123123123)
        XCTAssertEqual(uint, 123123123)
        XCTAssertEqual(zero, 0)
    }
    
    func testStringify() throws {
        let jsS = JSScriptBuilder(from: .optional(wrappedValue: .scalar(.string)), to: .scalar(.date))
        
        XCTAssertNoThrow(try String?.from(Date(), script: jsS.convertToFrom))
    }
    
    func testIntToFloat() throws {
        let script =
        """
        function convert(int) {
            let parsed = JSON.parse(int)
            return parsed.toFixed(1)
        }
        """
        
        let float = XCTAssertNoThrowWithResult(try Float.from(2, script: .init(script)))
        XCTAssert(float == 2.0)
    }
    
    func testNumberFloat() throws {
        let script = JSPrimitiveScript.numberFloat
        
        let number = try Int.from(2.2, script: script.convertToFrom)
        let float = try Float.from(number, script: script.convertFromTo)
        XCTAssertEqual(number, 2)
        XCTAssertEqual(float, 2.0)
    }
    
    func testUnsignedNumberFloat() throws {
        let script = JSPrimitiveScript.unsignedFloat
        
        let number = try UInt.from(2.2, script: script.convertToFrom)
        let float = try Float.from(number, script: script.convertFromTo)
        let zero = try UInt.from(-2.332, script: script.convertToFrom)
        XCTAssertEqual(number, 2)
        XCTAssertEqual(float, 2.0)
        XCTAssertEqual(zero, 0)
    }
    
    func testFloatToInt() throws {
        let script =
        """
        function convert(float) {
            let parsed = JSON.parse(float)
            return Math.round(parsed)
        }
        """
        
        XCTAssertEqual(2, try Int.from(2.0, script: .init(script)))
    }
    
    func testToString() throws {
        let script =
        """
        function convert(float) {
            let parsed = JSON.parse(float)
            return JSON.stringify(parsed.toString())
        }
        """
        
        let string = try String.from(2.1, script: .init(script))
        XCTAssertEqual(string, "2.1")
    }
    
    func testConvertBetweenTypeProps() throws {
        struct User1: Codable {
            let name: String
            let id: Int
        }
        
        struct User2: Codable {
            let name: String
            let id: String
        }
        
        let script =
        """
        function convert(one) {
            let parsed = JSON.parse(one)
            return JSON.stringify({ 'name': parsed.name, 'id': parsed.toString() })
        }
        """
        
        XCTAssertNoThrow(try User2.from(User1(name: "", id: 231), script: .init(script)))
    }
    
    func testPersist() throws {
        guard isEldisMacbook() else {
            return
        }
        try JSPrimitiveScript.allCombinations().write(at: Path.desktop.string, fileName: "all_combinations")
    }
    
    
    func testUUID() throws {
        let unsignedNumber = JSPrimitiveScript.uuid(to: .uint64)
        let boolScript = JSPrimitiveScript.uuid(to: .bool)
        
        let uuid = try UUID.from(123123123123, script: unsignedNumber.convertToFrom)
        let number = try UInt64.from(uuid, script: unsignedNumber.convertFromTo)
        
        XCTAssertEqual(number, 123123123123)
        
        XCTAssertNoThrow(try Bool.from(UUID(), script: boolScript.convertFromTo))
        XCTAssertNoThrow(try UUID.from(true, script: boolScript.convertToFrom))
    }
    
    func testBoolToString() throws {
        let script = JSPrimitiveScript.boolString
        
        XCTAssert(false == (try Bool.from("NO", script: script.convertToFrom)))
        XCTAssert("YES" == (try String.from(true, script: script.convertFromTo)))
    }
    
    func testBoolToNumber() throws {
        let script = JSPrimitiveScript.boolNumber
        
        XCTAssert(true == (try Bool.from(1, script: script.convertToFrom)))
        XCTAssert(0 == (try Double.from(false, script: script.convertFromTo)))
    }
    
    func testIdentity() throws {
        let js = JSPrimitiveScript.identity(for: .bool)
        
        XCTAssertNoThrow(try Double.from(Date().noon, script: js.convertToFrom))
    }
    
    func testIgonoreInput() throws {
        XCTAssertNoThrow(try Int.from(123123123123, script: .init(JSPrimitiveScript.stringify(to: .uint))))
    }
    
    func testArbitrary() throws {
        let floatToUUID: JSPrimitiveScript = .script(from: .float, to: .uuid)
        
        XCTAssertNoThrow(try Float.from(UUID(), script: floatToUUID.convertToFrom))
        XCTAssertNoThrow(try UUID.from(1234.1234, script: floatToUUID.convertFromTo))
    }
    
    func testArray() throws {
        /// exactly one to array -> JSON.stringify( to JSON.stringify([ and last index of ) -> ])
        let script =
        """
        function convert(string) {
            let parsed = JSON.parse(string)
            return JSON.stringify([parsed])
        }
        """
        let array = try [String].from("hello", script: .init(script))
        XCTAssert(array.first == "hello")
    }
    
    func testcomplexTypes() throws {
        guard isEldisMacbook() else {
            return
        }
        struct User: Codable {
            let id: UUID
            let name: String
            let age: Int
        }
        
        struct UserNew: Codable {
            let ident: UUID
            let name: String
        }
        
        let jsBuilder = JSScriptBuilder(from: try TypeInformation(type: User.self), to: try TypeInformation(type: UserNew.self))
        try jsBuilder.convertFromTo.write(at: Path.desktop.string, fileName: "user_to_userNew")
        try jsBuilder.convertToFrom.write(at: Path.desktop.string, fileName: "userNew_to_user")
        
        let newUser = UserNew(ident: .init(), name: "I am new user")
        let user = try User.from(newUser, script: jsBuilder.convertToFrom)
        XCTAssert(user.id == newUser.ident)
        XCTAssert(user.name == newUser.name)
        XCTAssert(user.age == 0)
    }
}
