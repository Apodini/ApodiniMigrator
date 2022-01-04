//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ApodiniMigrator
import ArgumentParser
import RESTMigrator
import gRPCMigrator

// MARK: - ExpressibleByArgument
extension ApodiniExporterType: ExpressibleByArgument {}

// MARK: MigratorType
extension ApodiniExporterType {
    func createMigrator(documentPath: String, migrationGuidePath: String? = nil) throws -> ApodiniMigrator.Migrator {
        switch self {
        case .rest:
            return try RESTMigrator(documentPath: documentPath, migrationGuidePath: migrationGuidePath)
        case .grpc:
            // TODO arguments!
            return try GRPCMigrator(protoFile: documentPath, migrationGuidePath: migrationGuidePath)
        }
    }
}
