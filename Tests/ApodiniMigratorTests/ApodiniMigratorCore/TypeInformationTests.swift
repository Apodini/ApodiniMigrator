import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport

final class TypeInformationTests: ApodiniMigratorXCTestCase {
    
    func testUserTypeInformation() throws {
        let user = XCTAssertNoThrowWithResult(try TypeInformation.of(TestTypes.User.self, with: RuntimeBuilder.self))
        
        XCTAssert(user.isObject)
        XCTAssert(user.rootType.description == "Object")
        XCTAssert(user.objectProperties.count == 9)
        XCTAssert(user.fileRenderableTypes().count == 5)
        XCTAssert(user.property("birthday")?.type == .repeated(element: .scalar(.date)))
        XCTAssert(user.property("name")?.necessity == .optional)
        XCTAssert(user.property("name")?.type.unwrapped.isScalar == true)
        XCTAssert(user.property("shops")?.type.isRepeated == true)
        XCTAssert(user.property("cars")?.type.isDictionary == true)
        XCTAssert(user.property("cars")?.type.dictionaryKey == .string)
        XCTAssert(user.property("cars")?.type.dictionaryValue?.isObject == true)
        XCTAssert(user.dictionaryKey == nil)
        XCTAssert(user.dictionaryValue == nil)
        XCTAssertEqual(user.nestedTypeString, "\(TestTypes.self)User")
        XCTAssertEqual(user.nestedTypeString.without("\(TestTypes.self)"), "User")
        XCTAssertEqual(user.property("otherCars")?.type.nestedTypeString.without("\(TestTypes.self)"), "Car")
        XCTAssert(user.property("url")?.type.objectProperties.isEmpty == true)
        XCTAssert(user.enumCases.isEmpty)
        XCTAssert(user.rawValueType == nil)
        XCTAssert(!user.scalars().isEmpty)
        XCTAssert(!user.repeatedTypes().isEmpty)
        XCTAssert(!user.dictionaries().isEmpty)
        XCTAssert(!user.enums().isEmpty)
        XCTAssert(!user.optionals().isEmpty)
        XCTAssert(!user.objectTypes().isEmpty)
        
        XCTAssertEqual(user.referencedProperties().property("birthday"), user.referencedProperties().property("birthday"))
        
        let allTypes = user.allTypes()
        XCTAssert(allTypes.contains(.scalar(.url)))
        XCTAssert(allTypes.contains(.scalar(.string)))
        XCTAssert(allTypes.contains(.scalar(.uuid)))
        XCTAssert(allTypes.contains(.scalar(.date)))
        XCTAssert(allTypes.contains(.scalar(.int)))
        XCTAssert(allTypes.contains(.scalar(.uint)))
        XCTAssert(!user.contains(.scalar(.bool)))
        XCTAssert(!user.contains(nil))
        
        let direction = try TypeInformation(type: TestTypes.Direction.self)
        XCTAssert(direction.isEnum)
        XCTAssert(user.contains(direction))
        XCTAssert(direction.isContained(in: user))
        
        XCTAssert(!user.sameType(with: direction))
        XCTAssertEqual(user.description, user.debugDescription)
        
        let data = user.description.data(using: .utf8) ?? Data()
        
        let userFromData = try TypeInformation.decode(from: data)
        XCTAssertEqual(user, userFromData)
        
        let userReference = user.asReference()
        let directionReference = direction.asReference()
        XCTAssert(userReference.isReference)
        XCTAssert(userReference.sameType(with: directionReference))
        XCTAssertNotEqual(userReference, directionReference)
    }
    
    func testTypeInformationConvenience() throws {
        let car = try TypeInformation(type: TestTypes.Car.self)
        let shop = try TypeInformation(type: TestTypes.Shop.self)
        let shopRepeated: TypeInformation = .repeated(element: shop)
        let direction = try TypeInformation(type: TestTypes.Direction.self)
        let someStruct: TypeInformation = .dictionary(key: .string, value: try TypeInformation(type: TestTypes.SomeStruct.self))
        
        XCTAssert(shopRepeated.referencedProperties().isRepeated)
        XCTAssert(direction.referencedProperties() == direction)
        XCTAssert(someStruct.asOptional.referencedProperties().isOptional)
        XCTAssert(shopRepeated.objectType == shop)
        XCTAssert(car.isContained(in: shop))
    }
    
    /// testing recursive storing and reconstructing in `TypesStore`
    func testTypeStore() throws {
        let typeInformation = try TypeInformation(type: [Int: [UUID: TestTypes.User?????]].self)
        
        var store = TypesStore()
        
        let reference = store.store(typeInformation) /// storing and retrieving a reference

        let result = store.construct(from: reference) /// reconstructing type from the reference
        
        XCTAssertEqual(result, typeInformation)
        XCTAssertEqual(store.store(.scalar(.string)), .scalar(.string))
    }
    
    func testJSONCreation() throws {
        let json = XCTAssertNoThrowWithResult(try JSONStringBuilder.jsonString(TestTypes.Student.self))
        
        let instance = XCTAssertNoThrowWithResult(try TestTypes.Student.decode(from: json))
        XCTAssert(instance.grades.isEmpty)
        XCTAssert(instance.age == 0)
        XCTAssert(instance.name == "")
    }
}
