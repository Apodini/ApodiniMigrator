import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class ModelsComparatorTests: ApodiniMigratorXCTestCase {
    let user: TypeInformation = .object(
        name: .init(name: "User"),
        properties: [
            .init(name: "id", type: .scalar(.uuid)),
            .init(name: "name", type: .scalar(.string)),
            .init(name: "age", type: .scalar(.uint)),
            .init(name: "githubProfile", type: .scalar(.url))
        ]
    )
    
    var renamedUser: TypeInformation {
        .object(name: .init(name: "UserNew"), properties: user.objectProperties)
    }
    
    let programmingLanguages: TypeInformation = .enum(
        name: .init(name: "ProgLang"),
        rawValueType: .scalar(.string),
        cases: [
            .init("swift"),
            .init("python"),
            .init("java"),
            .init("other")
        ]
    )
    
    override func setUp() {
        super.setUp()
        
        node = ChangeContextNode(compareConfiguration: .active)
    }
    
    func testNoModelsChange() throws {
        let modelsComparator = ModelsComparator(lhs: [user, programmingLanguages], rhs: [programmingLanguages, user], changes: node, configuration: .default)
        modelsComparator.compare()
        XCTAssert(node.isEmpty)
    }
    
    func testModelDeleted() throws {
        let modelsComparator = ModelsComparator(lhs: [user, programmingLanguages], rhs: [user], changes: node, configuration: .default)
        modelsComparator.compare()
        XCTAssert(node.changes.count == 1)
        let deleteChange = try XCTUnwrap(node.changes.first as? DeleteChange)
        
        XCTAssert(deleteChange.element == .enum(programmingLanguages.deltaIdentifier, target: .`self`))
        XCTAssert(!deleteChange.breaking)
        XCTAssert(!deleteChange.solvable)
        XCTAssert(deleteChange.fallbackValue == .none)
        XCTAssert(deleteChange.providerSupport == .renameHint(DeleteChange.self))
        if let providerSupport = deleteChange.providerSupport {
            let decodedInstance = XCTAssertNoThrowWithResult(try ProviderSupport.decode(from: providerSupport.json))
            XCTAssert(decodedInstance == deleteChange.providerSupport)
            XCTAssertNoThrow(try ProviderSupport.decode(from: "{}"))
        }
    }
    
    func testModelAdded() throws {
        let modelsComparator = ModelsComparator(lhs: [user], rhs: [user, programmingLanguages], changes: node, configuration: .default)
        modelsComparator.compare()
        XCTAssert(node.changes.count == 1)
        let addChange = try XCTUnwrap(node.changes.first as? AddChange)
        
        XCTAssert(addChange.element == .enum(programmingLanguages.deltaIdentifier, target: .`self`))
        XCTAssert(!addChange.breaking)
        XCTAssert(addChange.providerSupport == .renameHint(AddChange.self))
        XCTAssert(addChange.solvable)
    
        if case let .element(codable) = addChange.added {
            XCTAssert(codable.typed(TypeInformation.self) == programmingLanguages)
        } else {
            XCTFail("Added enumeration was not stored in the change object")
        }
    }
    
    func testModelRenamed() throws {
        let endpointsComparator = ModelsComparator(lhs: [user], rhs: [renamedUser], changes: node, configuration: .default)
        endpointsComparator.compare()
        XCTAssert(node.changes.count == 1)
        let renameChange = try XCTUnwrap(node.changes.first as? UpdateChange)
        let providerSupport = try XCTUnwrap(renameChange.providerSupport)
        
        XCTAssert(renameChange.element == .object(user.deltaIdentifier, target: .typeName))
        XCTAssert(!renameChange.breaking)
        XCTAssert(renameChange.solvable)
        XCTAssert(renameChange.type == .rename)
        XCTAssert(providerSupport == .renameValidationHint)
        
        if case let .stringValue(value) = renameChange.to, let similarity = renameChange.similarity {
            XCTAssert(value == "UserNew")
            XCTAssert(similarity > 0.5)
        } else {
            XCTFail("Rename change did not store the updated string value of the new type name")
        }
    }
    
    func testJSObjectScriptForRenamedType() {
        let obj1: TypeInformation = .object(name: .init(name: "Test"), properties: [.init(name: "prop1", type: user)])
        let obj2: TypeInformation = .object(name: .init(name: "Test"), properties: [.init(name: "prop1", type: renamedUser)])
        let comp2 = ModelsComparator(lhs: [obj1, user], rhs: [obj2, renamedUser], changes: node, configuration: .default)
        comp2.compare()
        
        let scriptBuilder = JSObjectScript(from: obj1, to: obj2, changes: node, encoderConfiguration: .default)
        XCTAssert(scriptBuilder.convertFromTo.rawValue.contains("'prop1': parsedFrom.prop1"))
        XCTAssert(scriptBuilder.convertToFrom.rawValue.contains("'prop1': parsedTo.prop1"))
    }
    
    func testUnsupportedTypeChange() throws {
        let changedUser: TypeInformation = .enum(
            name: .init(name: "User"),
            rawValueType: .scalar(.string),
            cases: []
        )
        let endpointsComparator = ModelsComparator(lhs: [user], rhs: [changedUser], changes: node, configuration: .default)
        endpointsComparator.compare()
        XCTAssert(node.changes.count == 1)
        
        let change = try XCTUnwrap(node.changes.first as? UnsupportedChange)
        XCTAssert(change.element == .object(user.deltaIdentifier, target: .`self`))
        XCTAssertEqual(change.type, .unsupported)
        XCTAssert(change.breaking)
        XCTAssert(!change.solvable)
    }
}
