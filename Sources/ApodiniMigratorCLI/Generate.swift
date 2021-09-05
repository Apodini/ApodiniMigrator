//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser
import ApodiniMigrator

struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to generate a client library out of a API document"
    )
    
    @Option(name: .shortAndLong, help: "Name of the package")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json")
    var documentPath: String
    
    func run() throws {
        let migrator = ApodiniMigrator.Migrator.self
        let logger = migrator.logger
        
        logger.info("Starting generation of package \(packageName)")
        
        do {
            let generator = try migrator.init(
                packageName: packageName,
                packagePath: targetDirectory,
                documentPath: documentPath
            )
            try generator.run()
            logger.info("Package \(packageName) was generated successfully. You can open the package via \(packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error)")
        }
    }
}
