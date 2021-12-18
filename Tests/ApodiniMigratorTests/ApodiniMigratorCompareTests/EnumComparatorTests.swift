//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class EnumComparatorTests: ApodiniMigratorXCTestCase {
    var modelChanges = [ModelChange]()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        modelChanges.removeAll()
    }

    let enumeration: TypeInformation = .enum(
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
        
        node = ChangeContextNode(compareConfiguration: .active)
    }
    
    func testNoEnumChange() {
        let comparator = EnumComparator(lhs: enumeration, rhs: enumeration)
        comparator.compare(comparisonContext, &modelChanges)
        XCTAssertEqual(modelChanges.isEmpty, true)
    }
    
    func testDeletedEnumCase() throws {
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .scalar(.string), cases: enumeration.enumCases.filter { $0.name != "other" })

        let comparator = EnumComparator(lhs: enumeration, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, enumeration.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        guard case let .case(caseChange) = updateChange.updated else {
            XCTFail("Change did not store the updated enum case")
            return
        }

        XCTAssertEqual(caseChange.id, "other")
        XCTAssertEqual(caseChange.type, .removal)
        XCTAssertEqual(change.breaking, caseChange.breaking)
        XCTAssertEqual(change.solvable, caseChange.solvable)

        let caseRemoval = try XCTUnwrap(caseChange.modeledRemovalChange)
        XCTAssertEqual(caseRemoval.removed, nil)
        XCTAssertEqual(caseRemoval.fallbackValue, nil)
    }
    
    func testRenamedEnumCases() throws {
        let cases = enumeration.enumCases.filter { $0.name != "swift" } + .init("swiftLang")
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .scalar(.string), cases: cases)

        let comparator = EnumComparator(lhs: enumeration, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 2) // update of the raw value as well
        let change = try XCTUnwrap(modelChanges.first) // TODO check if we have persistent order
        // TODO let change = try XCTUnwrap(node.changes.first(where: { $0.element.target == EnumTarget.case.rawValue }) as? UpdateChange)
        XCTAssertEqual(change.id, enumeration.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        guard case let .case(caseChange) = updateChange.updated else {
            XCTFail("Change did not store the updated enum case")
            return
        }

        XCTAssertEqual(caseChange.id, "swift")
        XCTAssertEqual(caseChange.type, .idChange)
        XCTAssertEqual(change.breaking, caseChange.breaking)
        XCTAssertEqual(change.solvable, caseChange.solvable)

        let caseRename = try XCTUnwrap(caseChange.modeledIdentifierChange)
        XCTAssertEqual(caseRename.from, caseChange.id)
        XCTAssertEqual(caseRename.to, "swiftLang")
        XCTAssert(try XCTUnwrap(caseRename.similarity) > 0.5)
    }
    
    func testAddedEnumCase() throws {
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .scalar(.string), cases: enumeration.enumCases + .init("newCase"))

        let comparator = EnumComparator(lhs: enumeration, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, enumeration.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        guard case let .case(caseChange) = updateChange.updated else {
            XCTFail("Change did not store the updated enum case")
            return
        }

        XCTAssertEqual(caseChange.id, "newCase")
        XCTAssertEqual(caseChange.type, .addition)
        XCTAssertEqual(change.breaking, caseChange.breaking)
        XCTAssertEqual(change.solvable, caseChange.solvable)

        let caseAddition = try XCTUnwrap(caseChange.modeledAdditionChange)
        XCTAssertEqual(caseAddition.added, EnumCase("newCase"))
        XCTAssertEqual(caseAddition.defaultValue, nil)
    }
    
    func testUnsupportedRawValueTypeChange() throws {
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .scalar(.int), cases: enumeration.enumCases)

        let comparator = EnumComparator(lhs: enumeration, rhs: updated)
        comparator.compare(comparisonContext, &modelChanges)

        XCTAssertEqual(modelChanges.count, 1)
        let change = try XCTUnwrap(modelChanges.first)
        XCTAssertEqual(change.id, enumeration.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, false)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        guard case let .rawValueType(from, to) = updateChange.updated else {
            XCTFail("Change did not store the updated raw value type")
            return
        }

        XCTAssertEqual(from, .scalar(.string))
        XCTAssertEqual(to, .scalar(.int))
    }
    
    func testIgnoreCompareWithNonEnum() {
        XCTAssertRuntimeFailure(EnumComparator(lhs: self.enumeration, rhs: .scalar(.bool)))
    }
}
