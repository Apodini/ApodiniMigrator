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

final class EndpointsComparatorTests: ApodiniMigratorXCTestCase {
    var endpointChanges = [EndpointChange]()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        endpointChanges.removeAll()
    }

    private let lhs = Endpoint(
        handlerName: "handlerName",
        deltaIdentifier: "runTests",
        operation: .read,
        communicationalPattern: .requestResponse,
        absolutePath: "/v1/tests",
        parameters: [],
        response: .scalar(.bool),
        errors: []
    )
    
    private let rhs = Endpoint(
        handlerName: "handlerName",
        deltaIdentifier: "runningTests",
        operation: .read,
        communicationalPattern: .requestResponse,
        absolutePath: "/v1/tests",
        parameters: [],
        response: .scalar(.bool),
        errors: []
    )
    
    override func setUp() {
        super.setUp()

        comparisonContext = ChangeComparisonContext(configuration: .active)
    }
    
    func testNoEndpointsChange() throws {
        let comparator = EndpointsComparator(lhs: [lhs], rhs: [lhs])
        comparator.compare(comparisonContext, &endpointChanges)
        XCTAssertEqual(endpointChanges.isEmpty, true)
    }
    
    func testEndpointDeleted() throws {
        let comparator = EndpointsComparator(lhs: [lhs], rhs: [])
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .removal)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, false)

        let removalChange = try XCTUnwrap(change.modeledRemovalChange)
        XCTAssertEqual(removalChange.removed, nil)
        XCTAssertEqual(removalChange.fallbackValue, nil)
        // TODO XCTAssert(deleteChange.providerSupport == .renameHint(DeleteChange.self))
    }
    
    func testEndpointAdded() throws {
        let comparator = EndpointsComparator(lhs: [], rhs: [lhs])
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .addition)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)

        let additionChange = try XCTUnwrap(change.modeledAdditionChange)
        XCTAssertEqual(additionChange.added, lhs)
        XCTAssertEqual(additionChange.defaultValue, nil)
        // TODO XCTAssert(addChange.providerSupport == .renameHint(AddChange.self))
    }
    
    func testEndpointRenamed() throws {
        let comparator = EndpointsComparator(lhs: [lhs], rhs: [rhs])
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .idChange)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)

        let idChange = try XCTUnwrap(change.modeledIdentifierChange)
        XCTAssertEqual(idChange.from, change.id)
        XCTAssertEqual(idChange.to, rhs.deltaIdentifier)
        XCTAssert(try XCTUnwrap(idChange.similarity) > 0.5)
        // TODO XCTAssert(providerSupport == .renameValidationHint)
    }
}
