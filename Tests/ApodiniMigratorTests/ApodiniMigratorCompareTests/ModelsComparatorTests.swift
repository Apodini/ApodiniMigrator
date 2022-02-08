//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class ModelsComparatorTests: ApodiniMigratorXCTestCase {
    var modelChanges = [ModelChange]()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        modelChanges.removeAll()
    }

    let user: TypeInformation = .object(
        name: .init(rawValue: "User"),
        properties: [
            .init(name: "id", type: .scalar(.uuid)),
            .init(name: "name", type: .scalar(.string)),
            .init(name: "age", type: .scalar(.uint)),
            .init(name: "githubProfile", type: .scalar(.url))
        ]
    )
    
    var renamedUser: TypeInformation {
        .object(name: .init(rawValue: "UserNew"), properties: user.objectProperties)
    }
    
    let programmingLanguages: TypeInformation = .enum(
        name: .init(rawValue: "ProgLang"),
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

        comparisonContext = ChangeComparisonContext(configuration: .active)
    }
    
    func testModelComparatorCommutativity() throws {
        let comparator = ModelsComparator(lhs: [user, programmingLanguages], rhs: [programmingLanguages, user])
        comparator.compare(comparisonContext, &modelChanges)
        XCTAssert(modelChanges.isEmpty)
    }
    
    func testModelDeleted() throws {
        let comparator = ModelsComparator(lhs: [user, programmingLanguages], rhs: [user])
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, programmingLanguages.deltaIdentifier)
        XCTAssertEqual(change.type, .removal)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, false)

        let removalChange = try XCTUnwrap(change.modeledRemovalChange)
        XCTAssertEqual(removalChange.removed, nil)
        XCTAssertEqual(removalChange.fallbackValue, nil)
    }
    
    func testModelAdded() throws {
        let comparator = ModelsComparator(lhs: [user], rhs: [user, programmingLanguages])
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, programmingLanguages.deltaIdentifier)
        XCTAssertEqual(change.type, .addition)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)

        let additionChange = try XCTUnwrap(change.modeledAdditionChange)
        XCTAssertEqual(additionChange.added, programmingLanguages)
    }
    
    func testModelRenamed() throws {
        let comparator = ModelsComparator(lhs: [user], rhs: [renamedUser])
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .idChange)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)

        let idChange = try XCTUnwrap(change.modeledIdentifierChange)
        XCTAssertEqual(idChange.to, "UserNew")
        XCTAssert(try XCTUnwrap(idChange.similarity) > 0.5)
    }
    
    func testJSObjectScriptForRenamedType() {
        let obj1: TypeInformation = .object(name: .init(rawValue: "Test"), properties: [.init(name: "prop1", type: user)])
        let obj2: TypeInformation = .object(name: .init(rawValue: "Test"), properties: [.init(name: "prop1", type: renamedUser)])

        let comparator = ModelsComparator(lhs: [obj1, user], rhs: [obj2, renamedUser])
        comparator.compare(comparisonContext, &modelChanges)
        comparisonContext.modelChanges = modelChanges

        let scriptBuilder = JSObjectScript(from: obj1, to: obj2, context: comparisonContext)
        XCTAssert(scriptBuilder.convertFromTo.rawValue.contains("'prop1': parsedFrom.prop1"))
        XCTAssert(scriptBuilder.convertToFrom.rawValue.contains("'prop1': parsedTo.prop1"))
    }
    
    func testUnsupportedTypeChange() throws {
        let changedUser: TypeInformation = .enum(
            name: .init(rawValue: "User"),
            rawValueType: .scalar(.string),
            cases: []
        )

        let comparator = ModelsComparator(lhs: [user], rhs: [changedUser])
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, false)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        if case let .rootType(from, to, newModel) = updateChange.updated {
            XCTAssertEqual(from, .object)
            XCTAssertEqual(to, .enum)
            XCTAssertEqual(newModel, changedUser)
        } else {
            XCTFail("Encountered unexpected update change: \(updateChange)")
        }
    }
}
