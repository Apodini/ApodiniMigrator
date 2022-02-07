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
@testable import gRPCMigrator
@testable import ApodiniMigrator

extension FileHeaderComment {
    static func now() -> String {
        let date = FileHeaderComment.testsDate
        FileHeaderComment.testsDate = nil
        let comment = FileHeaderComment().renderableContent
        FileHeaderComment.testsDate = date
        return comment
    }
}

final class GRPCLibraryGenerationTests: ApodiniMigratorXCTestCase {
    override class func setUp() {
        super.setUp()

        FileHeaderComment.testsDate = .testsDate
    }

    func apiDocumentOption(path: Path) -> String {
        "APIDocument=\(path.absolute().description)"
    }

    func migrationGuideOption(path: Path) -> String {
        "MigrationGuide=\(path.absolute().description)"
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    func testQonectiqV1Plugin() throws {
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

    func testQonectiqV2Plugin() throws {
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

    func qonectiqTest(v2: Bool = false) throws {
        let path = Path(productsDirectory.path) + "protoc-gen-grpc-migrator"
        XCTAssert(path.exists)

        let migrator = XCTAssertNoThrowWithResult(try GRPCMigrator(
            protoFile: Documents.protoV1.bundlePath.string,
            documentPath: Documents.v1_2.bundlePath.string,
            migrationGuidePath: v2 ? Documents.migrationGuide_2.bundlePath.string : nil,
            protocPluginBinaryPath: path.description
        ))

        XCTAssertThrows(try migrator.run(packageName: "QONECTIQ", packagePath: testDirectory))
        throw XCTSkip() // disable till merged: https://github.com/Apodini/.github/pull/10

        let swiftFilePath = try testDirectoryPath.recursiveSwiftFiles()
        var swiftFileNames: [String] = []

        var pbFilePath: Path! // swiftlint:disable:this implicitly_unwrapped_optional
        var grpcFilePath: Path! // swiftlint:disable:this implicitly_unwrapped_optional

        for path in swiftFilePath {
            swiftFileNames.append(path.lastComponent)

            if path.lastComponent.hasSuffix("pb.swift") {
                pbFilePath = path
            } else if path.lastComponent.hasSuffix("grpc.swift") {
                grpcFilePath = path
            }
        }

        let templateFiles: [String] = [
            "Package.swift",
            "GRPCNetworking.swift",
            "GRPCNetworkingError.swift",
            "GRPCResponseStream.swift",
            "Google_Protobuf_Timestamp+Codable.swift",
            "Utils.swift",
            "QONECTIQ.pb.swift",
            "QONECTIQ.grpc.swift"
        ]

        for file in templateFiles {
            XCTAssert(swiftFileNames.contains(file))
        }

        // we can't control the FileHeaderComment Date formatting

        let pbFileContent = try pbFilePath.read(.utf8)
            .replacingOccurrences(of: FileHeaderComment.now(), with: FileHeaderComment().renderableContent)
        let grpcFileContent = try grpcFilePath.read(.utf8)
            .replacingOccurrences(of: FileHeaderComment.now(), with: FileHeaderComment().renderableContent)

        XCTAssertEqual(pbFileContent, (v2 ? OutputFiles.pbFileV2 : OutputFiles.pbFileV1).content())
        XCTAssertEqual(grpcFileContent, (v2 ? OutputFiles.grpcFileV2 : OutputFiles.grpcFileV1).content())
    }

    func testQonectiqV1Migrator() throws {
        try qonectiqTest(v2: false)
    }

    func testQonectiqV2Migrator() throws {
        try qonectiqTest(v2: true)
    }
}
