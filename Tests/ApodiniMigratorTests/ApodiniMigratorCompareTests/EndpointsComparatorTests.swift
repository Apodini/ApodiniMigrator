import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare
@testable import ApodiniMigratorClientSupport

final class EndpointsComparatorTests: ApodiniMigratorXCTestCase {
    private let lhs = Endpoint(
        handlerName: "handlerName",
        deltaIdentifier: "runTests",
        operation: .read,
        absolutePath: "/v1/tests",
        parameters: [],
        response: .scalar(.bool),
        errors: []
    )
    
    private let rhs = Endpoint(
        handlerName: "handlerName",
        deltaIdentifier: "runningTests",
        operation: .read,
        absolutePath: "/v1/tests",
        parameters: [],
        response: .scalar(.bool),
        errors: []
    )
    
    override func setUp() {
        super.setUp()
        
        node = ChangeContextNode(compareConfiguration: .active)
    }
    
    func testNoEndpointsChange() throws {
        let endpointsComparator = EndpointsComparator(lhs: [lhs], rhs: [lhs], changes: node, configuration: .default)
        endpointsComparator.compare()
        XCTAssert(node.changes.isEmpty)
    }
    
    func testEndpointDeleted() throws {
        let endpointsComparator = EndpointsComparator(lhs: [lhs], rhs: [], changes: node, configuration: .default)
        endpointsComparator.compare()
        XCTAssert(node.changes.count == 1)
        let deleteChange = try XCTUnwrap(node.changes.first as? DeleteChange)
        
        XCTAssert(deleteChange.breaking)
        XCTAssert(!deleteChange.solvable)
        XCTAssert(deleteChange.fallbackValue == .none)
        XCTAssert(deleteChange.providerSupport == .renameHint(DeleteChange.self))
    }
    
    func testEndpointAdded() throws {
        let endpointsComparator = EndpointsComparator(lhs: [], rhs: [lhs], changes: node, configuration: .default)
        endpointsComparator.compare()
        XCTAssert(node.changes.count == 1)
        let addChange = try XCTUnwrap(node.changes.first as? AddChange)
        
        XCTAssert(!addChange.breaking)
        XCTAssert(addChange.providerSupport == .renameHint(AddChange.self))
        XCTAssert(addChange.solvable)
    
        if case let .element(codable) = addChange.added {
            XCTAssert(codable.typed(Endpoint.self) == lhs)
        } else {
            XCTFail("Added endpoint was not stored in the change object")
        }
    }
    
    func testEndpointRenamed() throws {
        let endpointsComparator = EndpointsComparator(lhs: [lhs], rhs: [rhs], changes: node, configuration: .default)
        endpointsComparator.compare()
        XCTAssert(node.changes.count == 1)
        let renameChange = try XCTUnwrap(node.changes.first as? UpdateChange)
        
        let providerSupport = try XCTUnwrap(renameChange.providerSupport)
        XCTAssert(providerSupport == .renameValidationHint)
        XCTAssert(!renameChange.breaking)
        XCTAssert(renameChange.solvable)
    
        if case let .stringValue(value) = renameChange.to {
            XCTAssert(value == "runningTests")
        } else {
            XCTFail("Rename change did not store the updated string value of the endpoint identifier")
        }
    }
}
