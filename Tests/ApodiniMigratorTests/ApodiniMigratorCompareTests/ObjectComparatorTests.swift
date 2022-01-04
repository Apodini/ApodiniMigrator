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

final class ObjectComparatorTests: ApodiniMigratorXCTestCase {
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
            .init(name: "isStudent", type: .scalar(.string)),
            .init(name: "age", type: .optional(wrappedValue: .scalar(.uint))),
            .init(name: "githubProfile", type: .scalar(.url)),
            .init(name: "friends", type: .repeated(element: .scalar(.uuid)))
        ]
    )
    
    override func setUp() {
        super.setUp()

        comparisonContext = ChangeComparisonContext(configuration: .active)
    }
    
    func testNoObjectChange() {
        let comparator = ObjectComparator(lhs: user, rhs: user)
        comparator.compare(comparisonContext, &modelChanges)
        XCTAssert(modelChanges.isEmpty)
    }
    
    func testAddedObjectProperty() throws {
        let newProperty: TypeProperty = .init(name: "birthday", type: .scalar(.date))
        let updated: TypeInformation = .object(name: user.typeName, properties: user.objectProperties + newProperty)

        let comparator = ObjectComparator(lhs: user, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        guard case let .property(propertyChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(propertyChange.type, .addition)
        XCTAssertEqual(change.breaking, propertyChange.breaking)
        XCTAssertEqual(change.solvable, propertyChange.solvable)
        XCTAssertEqual(propertyChange.id, newProperty.deltaIdentifier)

        let propertyAddition = try XCTUnwrap(propertyChange.modeledAdditionChange)
        XCTAssertEqual(propertyAddition.added, newProperty)

        if let defaultValue = propertyAddition.defaultValue,
           let json = comparisonContext.jsonValues[defaultValue] {
            XCTAssertNoThrow(try Date.instance(from: json))
        } else {
            XCTFail("Did not provide a default value for the added required property")
        }
    }
    
    func testDeletedProperty() throws {
        let updated: TypeInformation = .object(name: user.typeName, properties: user.objectProperties.filter { $0.name != "githubProfile" })

        let comparator = ObjectComparator(lhs: user, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        guard case let .property(propertyChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(propertyChange.type, .removal)
        XCTAssertEqual(change.breaking, propertyChange.breaking)
        XCTAssertEqual(change.solvable, propertyChange.solvable)
        XCTAssertEqual(propertyChange.id, "githubProfile")

        let propertyRemoval = try XCTUnwrap(propertyChange.modeledRemovalChange)
        XCTAssertEqual(propertyRemoval.removed, nil)

        if let fallbackValue = propertyRemoval.fallbackValue,
           let json = comparisonContext.jsonValues[fallbackValue] {
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

        let comparator = ObjectComparator(lhs: user, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .property(propertyChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(propertyChange.type, .idChange)
        XCTAssertEqual(change.breaking, propertyChange.breaking)
        XCTAssertEqual(change.solvable, propertyChange.solvable)
        XCTAssertEqual(propertyChange.id, "githubProfile")

        let propertyRename = try XCTUnwrap(propertyChange.modeledIdentifierChange)
        XCTAssertEqual(propertyRename.from, propertyChange.id)
        XCTAssertEqual(propertyRename.to, "github")
        XCTAssert(try XCTUnwrap(propertyRename.similarity) > 0.5)
    }
    
    func testPropertyNecessityToRequiredChange() throws {
        let updated: TypeInformation = .object(
            name: user.typeName,
            properties: user.objectProperties.filter { $0.name != "age" } + .init(name: "age", type: .scalar(.uint))
        )

        let comparator = ObjectComparator(lhs: user, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .property(propertyChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(propertyChange.type, .update)
        XCTAssertEqual(change.breaking, propertyChange.breaking)
        XCTAssertEqual(change.solvable, propertyChange.solvable)
        XCTAssertEqual(propertyChange.id, "age")

        let propertyUpdate = try XCTUnwrap(propertyChange.modeledUpdateChange)
        guard case let .necessity(from, to, necessityMigration) = propertyUpdate.updated else {
            XCTFail("Unexpected property update change: \(propertyUpdate.updated)")
            return
        }
        XCTAssertEqual(from, .optional)
        XCTAssertEqual(to, .required)

        if let json = comparisonContext.jsonValues[necessityMigration] {
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

        let comparator = ObjectComparator(lhs: user, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .property(propertyChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(propertyChange.type, .update)
        XCTAssertEqual(change.breaking, propertyChange.breaking)
        XCTAssertEqual(change.solvable, propertyChange.solvable)
        XCTAssertEqual(propertyChange.id, "name")

        let propertyUpdate = try XCTUnwrap(propertyChange.modeledUpdateChange)
        guard case let .necessity(from, to, necessityMigration) = propertyUpdate.updated else {
            XCTFail("Unexpected property update change: \(propertyUpdate.updated)")
            return
        }
        XCTAssertEqual(from, .required)
        XCTAssertEqual(to, .optional)

        if let json = comparisonContext.jsonValues[necessityMigration] {
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

        let comparator = ObjectComparator(lhs: user, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, user.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .property(propertyChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(propertyChange.type, .update)
        XCTAssertEqual(change.breaking, propertyChange.breaking)
        XCTAssertEqual(change.solvable, propertyChange.solvable)
        XCTAssertEqual(propertyChange.id, "isStudent")

        let propertyUpdate = try XCTUnwrap(propertyChange.modeledUpdateChange)
        guard case let .type(from, to, forwardMigration, backwardMigration, conversionWarning) = propertyUpdate.updated else {
            XCTFail("Unexpected property update change: \(propertyUpdate.updated)")
            return
        }

        XCTAssertEqual(from, .scalar(.string))
        XCTAssertEqual(to, .scalar(.bool))
        XCTAssertEqual(conversionWarning, nil)

        if let script = comparisonContext.scripts[forwardMigration] {
            XCTAssertEqual(false, try Bool.from("NO", script: script))
        } else {
            XCTFail("Did not provide the convert script for updated property type")
        }
        
        if let script = comparisonContext.scripts[backwardMigration] {
            XCTAssertEqual("YES", try String.from(true, script: script))
        } else {
            XCTFail("Did not provide the convert script for updated property type")
        }
    }
}
