import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorClientSupport
@testable import FluentKit
@testable import Runtime

func isEldisMacbook() -> Bool {
    Path.desktop.exists
}

final class InstanceCreatorTests: ApodiniMigratorXCTestCase {
    
    func testFluent() throws {
        guard isEldisMacbook() else {
            return
        }
        
        let contact = try TypeInformation(type: Contact.self)
        let residence = try TypeInformation(type: Residence.self)

        contact.write(at: .desktop, fileName: "Contact")
        residence.write(at: .desktop, fileName: "Residence")

        let planetTag = try TypeInformation(type: Planet.self)
        planetTag.write(at: .desktop, fileName: "PlanetTag")
    }
    
    
    func testInstanceCreate() throws {
        guard isEldisMacbook() else {
            return
        }
        
        enum Direction: Equatable {
            case left(some: String)
        }
        
        struct Student {
            let name: String
            let matrNr: UUID
            let dog: Direction
        }
        
        struct Dog: Codable, Equatable {
            let name: String
        }
        
        let contact = try JSONStringBuilder.instance(Contact.self)
        
        let typeInfo = try TypeInformation(type: Contact.self)
        
        typeInfo.write(at: .desktop, fileName: "ContactTypeInfo")
        contact.write(at: .desktop, fileName: "Contact")
        
        let runtimeInstance = try createInstance(of: Contact.self) as! Contact
        runtimeInstance.direction = .left
        runtimeInstance.id = .init()
        runtimeInstance.name = ""
        runtimeInstance.createdAt = .init()
    }
    
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
        XCTAssertEqual(try cardinality(of: Optional<Student>.self), .optional(Student.self))
        XCTAssertEqual(try cardinality(of: Array<Array<Student>>.self), .repeated(Array<Student>.self))
        XCTAssertEqual(try cardinality(of: Dictionary<Int, Student>.self), .dictionary(key: Int.self, value: Student.self))
    }
    
    func testInstanceCreateFluentModels() throws {
        /// creating instance out the json string, all properties set
        let contact1 = XCTAssertNoThrowWithResult(try JSONStringBuilder.instance(Contact.self))
        XCTAssert(contact1.id != nil)
        XCTAssert(contact1.name == "")
        XCTAssert(contact1.createdAt != nil)
        XCTAssert(contact1.direction == .left)
        
        let contact1JSON = contact1.json // encodes the instance again and returns json representation
        let contact1InstanceFromJSON = try Contact.decode(from: contact1JSON)
        XCTAssert(contact1InstanceFromJSON == contact1)
        
        /// Creating instance with `InstanceCreator`, none of the properties set
        let contact2 = XCTAssertNoThrowWithResult(try typedInstance(Contact.self))
        // uncommenting the next line, starts encoding the instance -> bad access
        // _ = contact2.json
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
    
    func testNonDetectionWrappedValue() throws {
        let idPropertyTypeInfo = try info(of: IDProperty<Contact, UUID>.self) // @ID of fluent
    
        /// wrapped value not found in fluent property wrappers
        XCTAssertThrowsError(try idPropertyTypeInfo.property(named: "wrappedValue"))
        
        /// wrapped value found in custom `EncodableContainer` property wrapper
        let intContainerTypeInfo = try info(of: EncodableContainer<Int>.self)
        XCTAssertNoThrow(try intContainerTypeInfo.property(named: "wrappedValue"))
    }
}
