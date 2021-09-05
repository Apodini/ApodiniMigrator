//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigrator

final class ClientLibraryGenerationMigrationTests: ApodiniMigratorXCTestCase {
    func testV1LibraryGeneration() throws {
        let document = try Documents.v1.instance() as Document
        let migrator = XCTAssertNoThrowWithResult(try Migrator(
            packageName: "QONECTIQ",
            packagePath: testDirectory,
            documentPath: Documents.v1.path.string
        ))
        
        XCTAssertNoThrow(try migrator.run())
        
        let swiftFiles = try testDirectoryPath.recursiveSwiftFiles().map { $0.lastComponent }
                
        let modelNames = document.allModels().map { $0.typeString + .swift }
        
        modelNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        let endpointFileNames = document.endpoints.map { $0.response.nestedTypeString + "+Endpoint" + .swift }.unique()
        
        endpointFileNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        XCTAssert(swiftFiles.contains("Handler.swift"))
        XCTAssert(swiftFiles.contains("NetworkingService.swift"))
        XCTAssert(swiftFiles.contains("QONECTIQTests.swift"))
    }
    
    func testV2LibraryGeneration() throws {
        let document = try Documents.v2.instance() as Document
        let migrator = XCTAssertNoThrowWithResult(try Migrator(
            packageName: "QONECTIQ",
            packagePath: testDirectory,
            documentPath: Documents.v2.path.string
        ))
        
        XCTAssertNoThrow(try migrator.run())
        
        let swiftFiles = try testDirectoryPath.recursiveSwiftFiles().map { $0.lastComponent }
                
        let modelNames = document.allModels().map { $0.typeString + .swift }
        
        modelNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        let endpointFileNames = document.endpoints.map { $0.response.nestedTypeString + "+Endpoint" + .swift }.unique()
        
        endpointFileNames.forEach { XCTAssert(swiftFiles.contains($0)) }
        
        XCTAssert(swiftFiles.contains("Handler.swift"))
        XCTAssert(swiftFiles.contains("NetworkingService.swift"))
        XCTAssert(swiftFiles.contains("QONECTIQTests.swift"))
    }
    
    func testMigratorThrowIncompatibleMigrationGuide() throws {
        let migrationGuide = try Documents.migrationGuide.instance() as MigrationGuide
        XCTAssertThrows(try Migrator(packageName: "Test", packagePath: testDirectory, documentPath: Documents.v2.path.string, migrationGuide: migrationGuide))
    }
    
    func testPackageMigration() throws {
        let migrationGuide = try MigrationGuide.decode(from: try Documents.migrationGuide.data())
        let migrator = XCTAssertNoThrowWithResult(try Migrator(
            packageName: "TestMigPackage",
            packagePath: testDirectory,
            documentPath: Documents.v1.path.string,
            migrationGuide: migrationGuide
        ))
        
        XCTAssertNoThrow(try migrator.run())
        XCTAssert(try testDirectoryPath.recursiveSwiftFiles().isNotEmpty)
    }
    
    func testMigrationGuideThrowing() throws {
        XCTAssertThrows(try MigrationGuide.from(Path(#file), .init(.endpoints)))
        XCTAssertThrows(try MigrationGuide.from("", ""))
    }
    
    func testMigrationGuideGeneration() throws {
        let doc1 = try Documents.v1.instance() as Document
        let doc2 = try Documents.v2.instance() as Document
        
        let migrationGuide = MigrationGuide(for: doc1, rhs: doc2)
        try (testDirectoryPath + "migration_guide.yaml").write(migrationGuide.yaml)

        let decoded = try MigrationGuide.decode(from: testDirectoryPath + "migration_guide.yaml")
        XCTAssertEqual(decoded, migrationGuide)
        XCTAssertNotEqual(decoded, .empty)
    }
}
