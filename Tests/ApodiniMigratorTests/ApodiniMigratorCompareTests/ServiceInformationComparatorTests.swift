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
        let updatedVersion = Version(prefix: "api", major: 2, minor: 0, patch: 0)
        let http = HTTPInformation(hostname: "test.com")

        let lhs = ServiceInformation(version: .default, http: http)
        let rhs = ServiceInformation(version: updatedVersion, http: http)

        let comparator = ServiceInformationComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &serviceChanges)
        
        XCTAssert(serviceChanges.count == 1)
        let change = try XCTUnwrap(serviceChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)

        let updateChange = try XCTUnwrap(change.modeledUpdateChange)
        if case let .version(from, to) = updateChange.updated {
            XCTAssertEqual(from, .default)
            XCTAssertEqual(to, updatedVersion)
        } else {
            XCTFail("Unexpected ServiceInformationUpdateChange: \(updateChange.updated)")
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
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .exporter(exporter) = updateChange.updated else {
            XCTFail("Unexpected ServiceInformationUpdateChange: \(updateChange.updated)")
            return
        }

        XCTAssertEqual(exporter.type, .update)
        XCTAssertEqual(exporter.breaking, change.breaking)
        XCTAssertEqual(exporter.solvable, change.solvable)
        XCTAssertEqual(exporter.id, DeltaIdentifier(ApodiniExporterType.rest.rawValue))

        let updatedExporter = try XCTUnwrap(exporter.modeledUpdateChange)
        XCTAssertEqual(updatedExporter.updated.from.typed(of: RESTExporterConfiguration.self), lhsExporter)
        XCTAssertEqual(updatedExporter.updated.to.typed(of: RESTExporterConfiguration.self), rhsExporter)
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

        guard case let .exporter(exporter) = updateChange.updated else {
            XCTFail("Unexpected ServiceInformationUpdateChange: \(updateChange.updated)")
            return
        }

        XCTAssertEqual(exporter.type, .update)
        XCTAssertEqual(exporter.breaking, change.breaking)
        XCTAssertEqual(exporter.solvable, change.solvable)
        XCTAssertEqual(exporter.id, DeltaIdentifier(ApodiniExporterType.rest.rawValue))

        let updatedExporter = try XCTUnwrap(exporter.modeledUpdateChange)
        XCTAssertEqual(updatedExporter.updated.from.typed(of: RESTExporterConfiguration.self), lhsExporter)
        XCTAssertEqual(updatedExporter.updated.to.typed(of: RESTExporterConfiguration.self), rhsExporter)
    }
}
