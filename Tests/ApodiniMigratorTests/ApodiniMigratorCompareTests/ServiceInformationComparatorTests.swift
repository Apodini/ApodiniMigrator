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

final class ServiceInformationComparatorTests: ApodiniMigratorXCTestCase {
    var serviceChanges = [ServiceInformationChange]()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        serviceChanges.removeAll()
    }

    func testServerPathChanged() throws {
        let lhs = ServiceInformation(version: .default, http: HTTPInformation(hostname: "www.test.com"))
        let rhs = ServiceInformation(version: .default, http: HTTPInformation(hostname: "www.updated.com"))

        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &serviceChanges)

        XCTAssertEqual(serviceChanges.count, 1)
        let change = try XCTUnwrap(serviceChanges.first)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        if case let .http(from, to) = updateChange.updated {
            XCTAssertEqual(from, lhs.http)
            XCTAssertEqual(to, rhs.http)
        } else {
            XCTFail("Unexpected ServiceInformationUpdateChange: \(updateChange.updated)")
        }
    }
    
    func testVersionChanged() throws {
        let http = HTTPInformation(hostname: "test.com")

        let lhs = ServiceInformation(version: .default, http: http)
        let rhs = ServiceInformation(version: Version(prefix: "api", major: 2, minor: 0, patch: 0), http: http)

        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &serviceChanges)
        
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
        let updatedConfiguration = EncoderConfiguration(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .base64)

        let lhsExporter = RESTExporterConfiguration(encoderConfiguration: .default, decoderConfiguration: .default)
        let rhsExporter = RESTExporterConfiguration(encoderConfiguration: updatedConfiguration, decoderConfiguration: .default)

        let http = HTTPInformation(hostname: "localhost")
        let lhs = ServiceInformation(version: .default, http: http, exporters: lhsExporter)
        let rhs = ServiceInformation(version: .default, http: http, exporters: rhsExporter)


        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &serviceChanges)

        XCTAssertEqual(serviceChanges.count, 1)
        let change = try XCTUnwrap(serviceChanges.first)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        if case let .exporter(exporter, from, to) = updateChange.updated {
            XCTAssertEqual(exporter, .rest)
            XCTAssertEqual(from as! RESTExporterConfiguration, lhsExporter)
            XCTAssertEqual(to as! RESTExporterConfiguration, rhsExporter)
        } else {
            XCTFail("Unexpected ServiceInformationUpdateChange: \(updateChange.updated)")
        }
    }
    
    func testDecoderConfigurationChanged() throws {
        let updatedConfiguration = DecoderConfiguration(dateDecodingStrategy: .secondsSince1970, dataDecodingStrategy: .base64)

        let lhsExporter = RESTExporterConfiguration(encoderConfiguration: .default, decoderConfiguration: .default)
        let rhsExporter = RESTExporterConfiguration(encoderConfiguration: .default, decoderConfiguration: updatedConfiguration)

        let http = HTTPInformation(hostname: "localhost")
        let lhs = ServiceInformation(version: .default, http: http, exporters: lhsExporter)
        let rhs = ServiceInformation(version: .default, http: http, exporters: rhsExporter)

        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &serviceChanges)

        XCTAssertEqual(serviceChanges.count, 1)
        let change = try XCTUnwrap(serviceChanges.first)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        if case let .exporter(exporter, from, to) = updateChange.updated {
            XCTAssertEqual(exporter, .rest)
            XCTAssertEqual(from as! RESTExporterConfiguration, lhsExporter)
            XCTAssertEqual(to as! RESTExporterConfiguration, rhsExporter)
        } else {
            XCTFail("Unexpected ServiceInformationUpdateChange: \(updateChange.updated)")
        }
    }

    // TODO add tests for grpc and addition/removal of exporters!
}
