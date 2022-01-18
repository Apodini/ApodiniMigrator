//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser
import gRPCMigrator

struct GenerateGRPC: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "grpc",
        abstract: "Generate a gRPC client library from an API document."
    )

    @OptionGroup
    var globalOptions: GlobalGenerateOptions

    @OptionGroup
    var grpcOptions: GRPCSpecificOptions

    func run() throws {
        let logger = GRPCMigrator.logger

        logger.info("Starting generation of package \(globalOptions.packageName)")

        do {
            let migrator = try GRPCMigrator(protoFile: grpcOptions.protoPath, documentPath: globalOptions.documentPath, migrationGuidePath: nil)

            try migrator.run(packageName: globalOptions.packageName, packagePath: globalOptions.targetDirectory)
            logger.info("Package \(globalOptions.packageName) was generated successfully. You can open the package via \(globalOptions.packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error)")
        }
    }
}
