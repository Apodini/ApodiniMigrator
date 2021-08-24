import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class EnumComparatorTests: ApodiniMigratorXCTestCase {
    let enumeration: TypeInformation = .enum(
        name: .init(name: "ProgLang"),
        rawValueType: .string,
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
        let enumComparator = EnumComparator(lhs: enumeration, rhs: enumeration, changes: node, configuration: .default)
        enumComparator.compare()
        XCTAssert(node.isEmpty)
    }
    
    func testDeletedEnumCase() throws {
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .string, cases: enumeration.enumCases.filter { $0.name != "other" })
        let enumComparator = EnumComparator(lhs: enumeration, rhs: updated, changes: node, configuration: .default)
        enumComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let deleteChange = try XCTUnwrap(node.changes.first as? DeleteChange)
        
        XCTAssert(deleteChange.element == .enum(enumeration.deltaIdentifier, target: .case))
        XCTAssert(deleteChange.breaking)
        XCTAssert(deleteChange.solvable)
        XCTAssert(deleteChange.fallbackValue == .none)
        XCTAssert(deleteChange.providerSupport == .renameHint(DeleteChange.self))
        if case let .elementID(id) = deleteChange.deleted {
            XCTAssert(id == "other")
        } else {
            XCTFail("Did not provide the id of the deleted enum case")
        }
    }
    
    func testRenamedEnumCases() throws {
        let cases = enumeration.enumCases.filter { $0.name != "swift" } + .init("swiftLang")
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .string, cases: cases)
        let enumComparator = EnumComparator(lhs: enumeration, rhs: updated, changes: node, configuration: .default)
        enumComparator.compare()
        
        XCTAssert(node.changes.count == 2) // update of the raw value as well
        let change = try XCTUnwrap(node.changes.first(where: { $0.element.target == EnumTarget.case.rawValue }) as? UpdateChange)
        XCTAssert(change.element == .enum(enumeration.deltaIdentifier, target: .case))
        XCTAssert(change.type == .rename)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .stringValue(value) = change.to, let similarity = change.similarity {
            XCTAssert(value == "swiftLang")
            XCTAssert(similarity > 0.5)
        } else {
            XCTFail("Change did not provide the updated name of the enum case")
        }
    }
    
    func testAddedEnumCase() throws {
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .string, cases: enumeration.enumCases + .init("newCase"))
        let enumComparator = EnumComparator(lhs: enumeration, rhs: updated, changes: node, configuration: .default)
        enumComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? AddChange)
        
        XCTAssert(change.element == .enum(enumeration.deltaIdentifier, target: .case))
        XCTAssert(!change.breaking)
        XCTAssert(change.solvable)
        XCTAssert(change.providerSupport == .renameHint(AddChange.self))
        if case let .element(codable) = change.added {
            XCTAssert(codable.typed(EnumCase.self) == .init("newCase"))
        } else {
            XCTFail("Did not provide the added enum case")
        }
    }
    
    func testUnsupportedRawValueTypeChange() throws {
        let updated: TypeInformation = .enum(name: enumeration.typeName, rawValueType: .int, cases: enumeration.enumCases)
        let enumComparator = EnumComparator(lhs: enumeration, rhs: updated, changes: node, configuration: .default)
        enumComparator.compare()
        
        XCTAssert(node.changes.count == 1)
        
        let change = try XCTUnwrap(node.changes.first as? UnsupportedChange)
        XCTAssert(change.element == .enum(enumeration.deltaIdentifier, target: .`self`))
        XCTAssertEqual(change.type, .unsupported)
        XCTAssert(change.breaking)
        XCTAssert(!change.solvable)
    }
    
    func testIgnoreCompareWithNonEnum() {
        let enumComparator = EnumComparator(lhs: enumeration, rhs: .scalar(.bool), changes: node, configuration: .default)
        enumComparator.compare()
        XCTAssert(node.isEmpty)
    }
}
