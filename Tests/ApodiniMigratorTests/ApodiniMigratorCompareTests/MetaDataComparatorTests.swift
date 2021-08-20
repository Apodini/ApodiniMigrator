import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare
@testable import ApodiniMigratorClientSupport

final class MetaDataComparatorTests: ApodiniMigratorXCTestCase {
    func testServerPathChanged() throws {
        let lhs = MetaData(serverPath: "www.test.com", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let rhs = MetaData(serverPath: "www.updated.com", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        
        let comparator = MetaDataComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        comparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let serverPathChange = try XCTUnwrap(node.changes.first)
        XCTAssert(serverPathChange is UpdateChange)
        XCTAssert(serverPathChange.breaking)
        XCTAssert(serverPathChange.solvable)
        XCTAssert(serverPathChange.element == .networking(target: .serverPath))
    }
    
    func testVersionChanged() throws {
        let lhs = MetaData(serverPath: "www.test.com", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let rhs = MetaData(serverPath: "www.test.com", version: .init(prefix: "api", major: 1, minor: 0, patch: 0), encoderConfiguration: .default, decoderConfiguration: .default)
        
        let comparator = MetaDataComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        comparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let serverPathChange = try XCTUnwrap(node.changes.first)
        XCTAssert(serverPathChange is UpdateChange)
        XCTAssert(serverPathChange.breaking)
        XCTAssert(serverPathChange.solvable)
        XCTAssert(serverPathChange.element == .networking(target: .serverPath))
    }
    
    func testEncoderConfigurationChanged() throws {
        let lhs = MetaData(serverPath: "", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let updatedConfiguration = EncoderConfiguration(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .base64)
        let rhs = MetaData(serverPath: "", version: .default, encoderConfiguration: updatedConfiguration, decoderConfiguration: .default)
        
        let comparator = MetaDataComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        comparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        XCTAssert(change.element == .networking(target: .encoderConfiguration))
        
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(EncoderConfiguration.self) == updatedConfiguration)
        } else {
            XCTFail("Change did not store the updated configuration")
        }
    }
    
    func testDecoderConfigurationChanged() throws {
        let lhs = MetaData(serverPath: "", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let updatedConfiguration = DecoderConfiguration(dateDecodingStrategy: .secondsSince1970, dataDecodingStrategy: .base64)
        let rhs = MetaData(serverPath: "", version: .default, encoderConfiguration: .default, decoderConfiguration: updatedConfiguration)
        
        let comparator = MetaDataComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        comparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        XCTAssert(change.element == .networking(target: .decoderConfiguration))
        
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(DecoderConfiguration.self) == updatedConfiguration)
        } else {
            XCTFail("Change did not store the updated configuration")
        }
    }
}
