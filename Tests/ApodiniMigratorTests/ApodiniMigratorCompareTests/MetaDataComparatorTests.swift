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

final class MetaDataComparatorTests: ApodiniMigratorXCTestCase {
    func testServerPathChanged() throws {
        let lhs = ServiceInformation(serverPath: "www.test.com", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let rhs = ServiceInformation(serverPath: "www.updated.com", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        
        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        comparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let serverPathChange = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(serverPathChange.breaking)
        XCTAssert(serverPathChange.solvable)
        XCTAssert(serverPathChange.type == .update)
        XCTAssert(serverPathChange.element == .networking(target: .serverPath))
        if case let .stringValue(value) = serverPathChange.to {
            XCTAssert(value == "www.updated.com/v1")
        } else {
            XCTFail("Change did not store the updated server path")
        }
    }
    
    func testVersionChanged() throws {
        let lhs = ServiceInformation(serverPath: "www.test.com", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let rhs = ServiceInformation(serverPath: "www.test.com", version: .init(prefix: "api", major: 2, minor: 0, patch: 0), encoderConfiguration: .default, decoderConfiguration: .default)
        
        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        comparator.compare()
        
        XCTAssert(node.changes.count == 1)
        let serverPathChange = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(serverPathChange.type == .update)
        XCTAssert(serverPathChange.breaking)
        XCTAssert(serverPathChange.solvable)
        XCTAssert(serverPathChange.element == .networking(target: .serverPath))
        if case let .stringValue(value) = serverPathChange.to {
            XCTAssert(value == "www.test.com/api2")
        } else {
            XCTFail("Change did not store the updated server path")
        }
    }
    
    func testEncoderConfigurationChanged() throws {
        let lhs = ServiceInformation(serverPath: "", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let updatedConfiguration = EncoderConfiguration(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .base64)
        let rhs = ServiceInformation(serverPath: "", version: .default, encoderConfiguration: updatedConfiguration, decoderConfiguration: .default)
        
        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
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
        let lhs = ServiceInformation(serverPath: "", version: .default, encoderConfiguration: .default, decoderConfiguration: .default)
        let updatedConfiguration = DecoderConfiguration(dateDecodingStrategy: .secondsSince1970, dataDecodingStrategy: .base64)
        let rhs = ServiceInformation(serverPath: "", version: .default, encoderConfiguration: .default, decoderConfiguration: updatedConfiguration)
        
        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
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
