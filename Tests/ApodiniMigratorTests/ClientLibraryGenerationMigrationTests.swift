//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import RESTMigrator

final class ClientLibraryGenerationMigrationTests: ApodiniMigratorXCTestCase {
    func testV1LibraryGeneration() throws {
        let document = try Documents.v1.decodedContent() as APIDocument
        let migrator = XCTAssertNoThrowWithResult(try RESTMigrator(
            documentPath: Documents.v1.bundlePath.string
        ))
        
        XCTAssertNoThrow(try migrator.run(packageName: "QONECTIQ", packagePath: testDirectory))
        
        let swiftFiles = try testDirectoryPath.recursiveSwiftFiles().map { $0.lastComponent }
                
        let modelNames = document.models.map { $0.typeString + .swift }
        
        modelNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        let endpointFileNames = document.endpoints.map { $0.response.nestedTypeString + "+Endpoint" + .swift }.unique()
        
        endpointFileNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        XCTAssert(swiftFiles.contains("Handler.swift"))
        XCTAssert(swiftFiles.contains("NetworkingService.swift"))
        XCTAssert(swiftFiles.contains("QONECTIQTests.swift"))
    }
    
    func testV2LibraryGeneration() throws {
        let document = try Documents.v2.decodedContent() as APIDocument
        let migrator = XCTAssertNoThrowWithResult(try RESTMigrator(
            documentPath: Documents.v2.bundlePath.string
        ))
        
        XCTAssertNoThrow(try migrator.run(packageName: "QONECTIQ", packagePath: testDirectory))
        
        let swiftFiles = try testDirectoryPath.recursiveSwiftFiles().map { $0.lastComponent }
                
        let modelNames = document.models.map { $0.typeString + .swift }
        
        modelNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        let endpointFileNames = document.endpoints.map { $0.response.nestedTypeString + "+Endpoint" + .swift }.unique()
        
        endpointFileNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        XCTAssert(swiftFiles.contains("Handler.swift"))
        XCTAssert(swiftFiles.contains("NetworkingService.swift"))
        XCTAssert(swiftFiles.contains("QONECTIQTests.swift"))
    }
    
    func testMigratorThrowIncompatibleMigrationGuide() throws {
        XCTAssertThrows(try RESTMigrator(
            documentPath: Documents.v2.bundlePath.string,
            migrationGuidePath: Documents.migrationGuide.bundlePath.string
        ))
    }
    
    func testPackageMigration() throws {
        let migrator = XCTAssertNoThrowWithResult(try RESTMigrator(
            documentPath: Documents.v1.bundlePath.string,
            migrationGuidePath: Documents.migrationGuide.bundlePath.string
        ))
        
        XCTAssertNoThrow(try migrator.run(packageName: "TestMigPackage", packagePath: testDirectory))
        XCTAssertEqual(try testDirectoryPath.recursiveSwiftFiles().isEmpty, false)
    }
    
    func testMigrationGuideThrowing() throws {
        XCTAssertThrows(try MigrationGuide.from(Path(#file), .init("Endpoints")))
        XCTAssertThrows(try MigrationGuide.from("", ""))
    }
    
    func testMigrationGuideGenerationYAML() throws {
        let doc1 = try Documents.v1.decodedContent() as APIDocument
        let doc2 = try Documents.v2.decodedContent() as APIDocument
        
        let migrationGuide = MigrationGuide(for: doc1, rhs: doc2)
        try (testDirectoryPath + "migration_guide.yaml").write(migrationGuide.yaml)

        let decoded = try MigrationGuide.decode(from: testDirectoryPath + "migration_guide.yaml")
        XCTAssert(decoded == migrationGuide)
        XCTAssert(decoded != .empty)
    }

    func testMigrationGuideGenerationJSON() throws {
        let doc1 = try Documents.v1.decodedContent() as APIDocument
        let doc2 = try Documents.v2.decodedContent() as APIDocument

        let migrationGuide = MigrationGuide(for: doc1, rhs: doc2)
        try (testDirectoryPath + "migration_guide.json").write(migrationGuide.json)

        let decoded = try MigrationGuide.decode(from: testDirectoryPath + "migration_guide.json")
        XCTAssert(decoded == migrationGuide)
        XCTAssert(decoded != .empty)
    }
}
