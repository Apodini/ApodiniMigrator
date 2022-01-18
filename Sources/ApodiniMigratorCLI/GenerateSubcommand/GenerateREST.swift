//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser
import RESTMigrator

struct GenerateREST: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rest",
        abstract: "Generate a REST client library from an API document."
    )

    @OptionGroup
    var globalOptions: GlobalGenerateOptions

    func run() throws {
        let logger = RESTMigrator.logger

        logger.info("Starting generation of package \(globalOptions.packageName)")

        do {
            let migrator = try RESTMigrator(documentPath: globalOptions.documentPath, migrationGuidePath: nil)

            try migrator.run(packageName: globalOptions.packageName, packagePath: globalOptions.targetDirectory)
            logger.info("Package \(globalOptions.packageName) was generated successfully. You can open the package via \(globalOptions.packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error)")
        }
    }
}
