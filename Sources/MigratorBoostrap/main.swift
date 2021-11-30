//
// Created by Andreas Bauer on 09.11.21.
//

import Foundation
import MigratorAPI
import RESTMigrator
import gRPCMigrator

// let migrationGuide = try MigrationGuide.decode(from: migrationGuidePath.asPath)
let gRPCMigrationGuide = try MigrationGuide.decode(
    from: Path("/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/migration_guide.json")
)

let migrator = GRPCMigrator(
    protoFilePath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES",
    protoFile: "webservice.proto",
    migrationGuide: gRPCMigrationGuide
)

try migrator.run(
    packageName: "GRPCLibrary",
    packagePath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/CLIENTS"
)

let rest = try RESTMigrator(
    documentPath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/api_v1.0.0.json",
    migrationGuide: .empty
)

try rest.run(packageName: "RestLibrary", packagePath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/CLIENTS")

/*
let generator = try Migrator(
    packageName: "TestClient",
    packagePath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/CLIENT",
    documentPath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/api_v1.0.0.json",
    migrationGuide: .empty
)

try generator.run()
print("Success!");
*/