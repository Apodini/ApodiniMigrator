//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import RESTMigrator
import gRPCMigrator

// let migrationGuide = try MigrationGuide.decode(from: migrationGuidePath.asPath)
let migrationGuidePath = "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/migration_guide.json"

let migrator = try GRPCMigrator(
    protoFilePath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES",
    protoFile: "webservice.proto",
    migrationGuidePath: migrationGuidePath
)

try migrator.run(
    packageName: "GRPCLibrary",
    packagePath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/CLIENTS"
)

let rest = try RESTMigrator(
    documentPath: "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/api_v1.0.0.json"
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
