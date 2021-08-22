import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class ObjectComparatorTests: ApodiniMigratorXCTestCase {
    let user: TypeInformation = .object(
        name: .init(name: "User"),
        properties: [
            .init(name: "id", type: .scalar(.uuid)),
            .init(name: "name", type: .scalar(.string)),
            .init(name: "isStudent", type: .scalar(.string)),
            .init(name: "age", type: .optional(wrappedValue: .scalar(.uint))),
            .init(name: "githubProfile", type: .scalar(.url)),
            .init(name: "friends", type: .repeated(element: .scalar(.uuid)))
        ]
    )
    
    override func setUp() {
        super.setUp()
        
        node = ChangeContextNode(compareConfiguration: .active)
    }
    
    func testNoObjectChange() {
        let objectComparator = ObjectComparator(lhs: user, rhs: user, changes: node, configuration: .default)
        objectComparator.compare()
        XCTAssert(node.isEmpty)
    }
    
    func testAddedObjectProperty() throws {
        let newProperty: TypeProperty = .init(name: "birthday", type: .scalar(.date))
        let updated: TypeInformation = .object(name: user.typeName, properties: user.objectProperties + newProperty)
        let objectComparator = ObjectComparator(lhs: user, rhs: updated, changes: node, configuration: .default)
        objectComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? AddChange)
        XCTAssert(change.element == .object(user.deltaIdentifier, target: .property))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        XCTAssert(change.providerSupport == .renameHint(AddChange.self))
        if case let .element(codable) = change.added {
            XCTAssert(codable.typed(TypeProperty.self) == newProperty)
        } else {
            XCTFail("Did not provide the added property")
        }
        
        if case let .json(id) = change.defaultValue, let json = node.jsonValues[id] {
            XCTAssertNoThrow(try Date.instance(from: json))
        } else {
            XCTFail("Did not provide a default value for the added required property")
        }
    }
    
    func testDeletedProperty() throws {
        let updated: TypeInformation = .object(name: user.typeName, properties: user.objectProperties.filter { $0.name != "githubProfile" })
        let objectComparator = ObjectComparator(lhs: user, rhs: updated, changes: node, configuration: .default)
        objectComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let deleteChange = try XCTUnwrap(node.changes.first as? DeleteChange)
        
        XCTAssert(deleteChange.element == .object(user.deltaIdentifier, target: .property))
        XCTAssert(deleteChange.breaking)
        XCTAssert(deleteChange.solvable)
        XCTAssert(deleteChange.providerSupport == .renameHint(DeleteChange.self))
        if case let .elementID(id) = deleteChange.deleted {
            XCTAssert(id == .init("githubProfile"))
        } else {
            XCTFail("Did not provide the id of the deleted property")
        }
        
        if case let .json(id) = deleteChange.fallbackValue, let json = node.jsonValues[id] {
            XCTAssertNoThrow(try URL.instance(from: json))
        } else {
            XCTFail("Did not provide a fallback value of deleted property")
        }
    }

    func testRenamedProperty() throws {
        let updated: TypeInformation = .object(
            name: user.typeName,
            properties: user.objectProperties.filter { $0.name != "githubProfile" } + .init(name: "github", type: .scalar(.url))
        )
        
        let objectComparator = ObjectComparator(lhs: user, rhs: updated, changes: node, configuration: .default)
        objectComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .object(user.deltaIdentifier, target: .property))
        XCTAssert(change.type == .rename)
        XCTAssert(change.targetID == .init("githubProfile"))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .stringValue(value) = change.to, let similarity = change.similarity {
            XCTAssert(value == "github")
            XCTAssert(similarity > 0.5)
        } else {
            XCTFail("Change did not provide the updated name of the property")
        }
    }
    
    func testPropertyNecessityToRequiredChange() throws {
        let updated: TypeInformation = .object(
            name: user.typeName,
            properties: user.objectProperties.filter { $0.name != "age" } + .init(name: "age", type: .scalar(.uint))
        )
        
        let objectComparator = ObjectComparator(lhs: user, rhs: updated, changes: node, configuration: .default)
        objectComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .object(user.deltaIdentifier, target: .necessity))
        XCTAssert(change.type == .update)
        XCTAssert(change.targetID == .init("age"))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(Necessity.self) == .required)
        } else {
            XCTFail("Change did not provide the updated necessity of the property")
        }
        
        if case let .json(id) = change.necessityValue, let json = node.jsonValues[id] {
            XCTAssertNoThrow(try UInt.instance(from: json))
        } else {
            XCTFail("Did not provide a necessity value for the updated property")
        }
    }
    
    func testPropertyNecessityToOptionalChange() throws {
        let updated: TypeInformation = .object(
            name: user.typeName,
            properties: user.objectProperties.filter { $0.name != "name" } + .init(name: "name", type: .optional(wrappedValue: .scalar(.string)))
        )
        
        let objectComparator = ObjectComparator(lhs: user, rhs: updated, changes: node, configuration: .default)
        objectComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .object(user.deltaIdentifier, target: .necessity))
        XCTAssert(change.type == .update)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(Necessity.self) == .optional)
        } else {
            XCTFail("Change did not provide the updated necessity of the property")
        }
        
        if case let .json(id) = change.necessityValue, let json = node.jsonValues[id] {
            XCTAssertNoThrow(try String.instance(from: json))
        } else {
            XCTFail("Did not provide a necessity value for the updated property")
        }
    }
    
    func testPropertyTypeChange() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let updated: TypeInformation = .object(
            name: user.typeName,
            properties: user.objectProperties.filter { $0.name != "isStudent" } + .init(name: "isStudent", type: .scalar(.bool))
        )
        
        let objectComparator = ObjectComparator(lhs: user, rhs: updated, changes: node, configuration: .default)
        objectComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .object(user.deltaIdentifier, target: .property))
        XCTAssert(change.type == .propertyChange)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(TypeInformation.self) == .scalar(.bool))
        } else {
            XCTFail("Change did not provide the updated type of the property")
        }
        
        if let convertFromTo = change.convertFromTo, let script = node.scripts[convertFromTo] {
            XCTAssertEqual(false, try Bool.from("NO", script: script))
        } else {
            XCTFail("Did not provide the convert script for updated property type")
        }
        
        if let convertToFrom = change.convertToFrom, let script = node.scripts[convertToFrom] {
            XCTAssertEqual("YES", try String.from(true, script: script))
        } else {
            XCTFail("Did not provide the convert script for updated property type")
        }
    }
}
