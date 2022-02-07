//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
@testable import ApodiniMigrator
@testable import gRPCMigrator
import ApodiniDocumentExport

final class GPRCMigratorTests: ApodiniMigratorXCTestCase {
    func testIncompatibleDocumentIds() throws {
        let document = APIDocument(serviceInformation: .init(version: .default, http: .init(hostname: "localhost")))
        let migrationGuide = MigrationGuide.empty(id: UUID())

        let documentPath = testDirectoryPath + "api_document.json"
        try documentPath.write(OutputFormat.json.string(of: document))

        let guidePath = testDirectoryPath + "migration_guide.json"
        try guidePath.write(OutputFormat.json.string(of: migrationGuide))

        XCTAssertThrows(try GRPCMigrator(
            protoFile: Documents.protoV1.bundlePath.string,
            documentPath: documentPath.string,
            migrationGuidePath: guidePath.string
        ))
    }

    func testRemovedGPRCExporter() throws {
        let serviceInformation1 = ServiceInformation(
            version: .default,
            http: .init(hostname: "localhost"),
            exporters: [
                GRPCExporterConfiguration(packageName: "TestPackage", serviceName: "TestService", pathPrefix: "prefix", reflectionEnabled: true)
            ]
        )
        let serviceInformation2 = ServiceInformation(
            version: .default,
            http: .init(hostname: "localhost"),
            exporters: []
        )

        let apiDocument1 = APIDocument(serviceInformation: serviceInformation1)
        let apiDocument2 = APIDocument(serviceInformation: serviceInformation2)

        let guide = MigrationGuide(for: apiDocument1, rhs: apiDocument2)

        let documentPath = testDirectoryPath + "api_document1.json"
        try documentPath.write(OutputFormat.json.string(of: apiDocument1))

        let guidePath = testDirectoryPath + "migration_guide.json"
        try guidePath.write(OutputFormat.json.string(of: guide))

        XCTAssertThrows(try GRPCMigrator(
            protoFile: Documents.protoV1.bundlePath.string,
            documentPath: documentPath.string,
            migrationGuidePath: guidePath.string
        ))
    }
}
