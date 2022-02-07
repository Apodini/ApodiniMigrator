//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
import SwiftProtobufPluginLibrary
@testable import ProtocGRPCPluginLibrary
@testable import ApodiniMigrator

final class ProtocEnd2EndTests: ApodiniMigratorXCTestCase {
    override class func setUp() {
        super.setUp()

        FileHeaderComment.testsDate = .testsDate
    }

    // TODO test v2
    // TODO test v1
    func apiDocumentOption(path: Path) -> String {
        // ,MigrationGuide=/Users/andi/XcodeProjects/TUM/ApodiniMigrator/Resources/ExampleDocuments/migration_guide.json
        // ,APIDocument=/Users/andi/XcodeProjects/TUM/ApodiniMigrator/Resources/ExampleDocuments/api_v1.0.0.json
        "APIDocument=\(path.absolute().description)"
    }

    func migrationGuideOption(path: Path) -> String {
        "MigrationGuide=\(path.absolute().description)"
    }

    func testQonectiqV1() throws {
        let content = Documents.protobufCodeGeneratorRequest.content()

        let request = try Google_Protobuf_Compiler_CodeGeneratorRequest(jsonString: content)
        let options = try PluginOptions(parameter: "Visibility=Public," + apiDocumentOption(path: Documents.v1_2.bundlePath))

        var plugin = try ProtocPlugin(request: request, options: options)
        try plugin.generate()

        let response = plugin.response
        XCTAssert(!response.file.isEmpty)

        let pbFile = response.file[0]
        let grpcFile = response.file[1]
        XCTAssertEqual(pbFile.name, "QONECTIQ.pb.swift")
        XCTAssertEqual(grpcFile.name, "QONECTIQ.grpc.swift")

        XCTAssertEqual(pbFile.content, OutputFiles.pbFileV1.content())
        XCTAssertEqual(grpcFile.content, OutputFiles.grpcFileV1.content())
    }

    func testQonectiqV2() throws {
        let content = Documents.protobufCodeGeneratorRequest.content()

        let request = try Google_Protobuf_Compiler_CodeGeneratorRequest(jsonString: content)
        let options = try PluginOptions(
            parameter: "Visibility=Public," +
                apiDocumentOption(path: Documents.v1_2.bundlePath) +
                "," +
                migrationGuideOption(path: Documents.migrationGuide_2.bundlePath)
        )

        var plugin = try ProtocPlugin(request: request, options: options)
        try plugin.generate()

        let response = plugin.response
        XCTAssert(!response.file.isEmpty)

        let pbFile = response.file[0]
        let grpcFile = response.file[1]
        XCTAssertEqual(pbFile.name, "QONECTIQ.pb.swift")
        XCTAssertEqual(grpcFile.name, "QONECTIQ.grpc.swift")

        XCTAssertEqual(pbFile.content, OutputFiles.pbFileV2.content())
        XCTAssertEqual(grpcFile.content, OutputFiles.grpcFileV2.content())
    }
}
