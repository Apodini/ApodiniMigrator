//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare

fileprivate extension ApodiniMigratorCodable {
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

private typealias Codable = ApodiniMigratorCodable

final class JavaScriptConvertTests: ApodiniMigratorXCTestCase {
    func testComplexTypeScriptConvert() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        struct Student: Codable, Equatable {
            let name: String
            let matrNr: UUID
        }
        
        struct Developer: Codable, Equatable {
            let id: UUID
            let name: String
        }
        
        let studentScript: JSScript =
        """
        function convert(name, matrNr) {
            let parsedName = JSON.parse(name)
            let parsedMatrNr = JSON.parse(matrNr)
            return JSON.stringify({ 'name' : parsedName, 'matrNr' : parsedMatrNr })
        }
        """
        
        let student = try Student.fromValues("John", UUID(), script: studentScript)
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
    
    fileprivate struct Student: Codable, Equatable {
        let name: String
        let matrNr: UUID
        let dog: Dog
        let number: Int
    }
    
    fileprivate struct Dog: Codable, Equatable {
        let name: String
    }
    
    
    func testMultipleArguments() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let constructScript: JSScript =
        """
        function convert(name, matrNr, dog) {
            let parsedName = JSON.parse(name)
            let parsedMatrNr = JSON.parse(matrNr)
            let parsedDog = JSON.parse(dog)
            return JSON.stringify({ 'name' : parsedName, 'matrNr' : parsedMatrNr, 'dog' : parsedDog, 'number': 42 })
        }
        """
        
        let student1 = try Student.fromValues("John", UUID(), Dog(name: "Dog"), script: constructScript)
        
        XCTAssert(student1.dog.name == "Dog")
        XCTAssert(student1.name == "John")
        XCTAssert(student1.number == 42)
        
        
        let script: JSScript =
        """
        function convert(name, matrNr, dog, number) {
            let parsedName = JSON.parse(name)
            let parsedMatrNr = JSON.parse(matrNr)
            let parsedDog = JSON.parse(dog)
            let parsedNumber = JSON.parse(number)
            return JSON.stringify({ 'name' : parsedName, 'matrNr' : parsedMatrNr, 'dog' : parsedDog, 'number': parsedNumber })
        }
        """
        let id = UUID()
        let student2 = try Student.fromValues("Bernd", id, Dog(name: "Dog"), arg4: 1234, script: script)
        XCTAssert(student2.dog.name == "Dog")
        XCTAssert(student2.name == "Bernd")
        XCTAssert(student2.number == 1234)
        XCTAssert(student2.matrNr == id)
        
        let script5: JSScript =
        """
        function convert(arg1, arg2, arg3, arg4, arg5) {
            let parsedOne = JSON.parse(arg1)
            let parsedTwo = JSON.parse(arg2)
            let parsedThree = JSON.parse(arg3)
            let parsedFour = JSON.parse(arg4)
            let parsedFive = JSON.parse(arg5)
            return JSON.stringify({ 'name' : parsedOne + parsedTwo + parsedThree + parsedFour + parsedFive })
        }
        """
        
        let dog = XCTAssertNoThrowWithResult(try Dog.fromValues("I ", "am ", "not ", arg4: "a ", arg5: "dog!", script: script5))
        XCTAssert(dog.name == "I am not a dog!")
    }
    
    func testInvalidScript() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script: JSScript =
        """
        Hello World
        """
        let student = XCTAssertNoThrowWithResult(try Student.from(0, script: script))
        
        XCTAssert(student.dog.name == "")
        XCTAssert(student.name == "")
        XCTAssert(student.number == 0)
        
        let invalidConvert: JSScript =
        """
        function convert(name, matrNr, dog) {
            let parsedName = JSON.parse(name)
            let parsedMatrNr = JSON.parse(matrNr)
            let parsedDog = JSON.parse(dog)
            return JSON.stringify({ 'name' : parsedName, 'matrikelNummer' : parsedMatrNr, 'dog' : parsedDog, 'number': 42 })
        }
        """
        let secondStudent = try Student.fromValues("John", UUID(), Dog(name: "Dog"), script: invalidConvert)
        
        XCTAssert(secondStudent.dog.name == "")
        XCTAssert(secondStudent.name == "")
        XCTAssert(secondStudent.number == 0)
    }
    
    func testIntString() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.stringNumber
        
        let number = try Int.from("123123", script: script.convertFromTo)
        let string = try String.from(number, script: script.convertToFrom)
        let zero = try Int.from("helloWorld", script: script.convertFromTo)
        XCTAssertEqual(number, 123123)
        XCTAssertEqual(string, "123123")
        XCTAssertEqual(zero, 0)
    }
    
    func testFloatString() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.stringFloat
        
        let number = try Double.from("123123.2", script: script.convertFromTo)
        let string = try String.from(number, script: script.convertToFrom)
        let zero = try Float.from("helloWorld", script: script.convertFromTo)
        XCTAssertEqual(number, 123123.2)
        XCTAssertEqual(string, "123123.2")
        XCTAssertEqual(zero, 0)
    }
    
    func testNumberUnsigned() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.numberUnsignedNumber
        
        let number = try Int.from(123123123, script: script.convertFromTo)
        let uint = try UInt64.from(number, script: script.convertToFrom)
        let zero = try UInt64.from(-123123, script: script.convertFromTo)
        XCTAssertEqual(number, 123123123)
        XCTAssertEqual(uint, 123123123)
        XCTAssertEqual(zero, 0)
    }
    
    func testStringify() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let scriptBuilder = JSScriptBuilder(from: .optional(wrappedValue: .scalar(.string)), to: .scalar(.date))
        
        XCTAssertNoThrow(try String?.from(Date(), script: scriptBuilder.convertToFrom))
    }
    
    func testIntToFloat() throws {
        guard canImportJavaScriptCore() else {
            return
        }
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
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.numberFloat
        
        let number = try Int.from(2.2, script: script.convertToFrom)
        let float = try Float.from(number, script: script.convertFromTo)
        XCTAssertEqual(number, 2)
        XCTAssertEqual(float, 2.0)
    }
    
    func testUnsignedNumberFloat() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.unsignedFloat
        
        let number = try UInt.from(2.2, script: script.convertToFrom)
        let float = try Float.from(number, script: script.convertFromTo)
        let zero = try UInt.from(-2.332, script: script.convertToFrom)
        XCTAssertEqual(number, 2)
        XCTAssertEqual(float, 2.0)
        XCTAssertEqual(zero, 0)
    }
    
    func testFloatToInt() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script =
        """
        function convert(float) {
            let parsed = JSON.parse(float)
            return Math.round(parsed)
        }
        """
        
        XCTAssertEqual(2, try Int.from(2.0, script: .init(script)))
    }
    
    func testFloatToString() throws {
        guard canImportJavaScriptCore() else {
            return
        }
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
        guard canImportJavaScriptCore() else {
            return
        }
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
            return JSON.stringify({ 'name': parsed.name, 'id': parsed.id.toString() })
        }
        """
        let user2 = XCTAssertNoThrowWithResult(try User2.from(User1(name: "user", id: 231), script: .init(script)))
        XCTAssert(user2.name == "user")
        XCTAssert(user2.id == "231")
    }
    
    func testAllCombinations() throws {
        let combinations = JSPrimitiveScript.allCombinations()
        let primitives = PrimitiveType.allCases.count - 1
        XCTAssertEqual(combinations.count, primitives * (primitives - 1))
    }
    
    
    func testUUID() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let unsignedNumber = JSPrimitiveScript.uuid(to: .uint64)
        let boolScript = JSPrimitiveScript.uuid(to: .bool)
        let stringScript = JSPrimitiveScript.uuid(to: .string)
        
        let uuid = try UUID.from(123123123123, script: unsignedNumber.convertToFrom)
        let number = try UInt64.from(uuid, script: unsignedNumber.convertFromTo)
        
        XCTAssertEqual(number, 123123123123)
        
        XCTAssertNoThrow(try Bool.from(UUID(), script: boolScript.convertFromTo))
        XCTAssertNoThrow(try UUID.from(true, script: boolScript.convertToFrom))
        
        let stringUUID = XCTAssertNoThrowWithResult(try String.from(uuid, script: stringScript.convertFromTo))
        XCTAssertNoThrow(try UUID.from(stringUUID, script: stringScript.convertToFrom))
    }
    
    func testBoolToString() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.boolString
        
        XCTAssert(false == (try Bool.from("NO", script: script.convertToFrom)))
        XCTAssert("YES" == (try String.from(true, script: script.convertFromTo)))
    }
    
    func testBoolToNumber() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let script = JSPrimitiveScript.boolNumber
        
        XCTAssert(true == (try Bool.from(1, script: script.convertToFrom)))
        XCTAssert(0 == (try Double.from(false, script: script.convertFromTo)))
    }
    
    func testIdentity() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let js = JSPrimitiveScript.identity(for: .bool)
        
        XCTAssertNoThrow(try Double.from(Date(Default()), script: js.convertToFrom))
    }
    
    func testIgonoreInput() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        XCTAssertNoThrow(try Int.from(123123123123, script: .init(JSPrimitiveScript.stringify(to: .uint))))
    }
    
    func testArbitrary() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let floatToUUID: JSPrimitiveScript = .script(from: .float, to: .uuid)
        
        XCTAssertNoThrow(try Float.from(UUID(), script: floatToUUID.convertToFrom))
        XCTAssertNoThrow(try UUID.from(1234.1234, script: floatToUUID.convertFromTo))
    }
    
    func testArray() throws {
        guard canImportJavaScriptCore() else {
            return
        }
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
    
    func testComplexTypes() throws {
        guard canImportJavaScriptCore() else {
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
        
        let newUser = UserNew(ident: .init(), name: "I am new user")
        let user = try User.from(newUser, script: jsBuilder.convertToFrom)
        
        XCTAssert(user.id == newUser.ident)
        XCTAssert(user.name == newUser.name)
        XCTAssert(user.age == 0)
    }
}
