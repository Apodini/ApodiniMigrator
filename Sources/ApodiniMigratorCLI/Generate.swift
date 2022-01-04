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

struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to generate a client library out of a API document"
    )

    @Option(name: .shortAndLong, help: "Defines which type of client to generate")
    var libraryType: ApodiniExporterType
    
    @Option(name: .shortAndLong, help: "Name of the package")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json") // TODO proto file!
    var documentPath: String
    
    func run() throws {
        let logger = RESTMigrator.logger
        
        logger.info("Starting generation of package \(packageName)")
        
        do {
            let migrator = try libraryType.createMigrator(documentPath: documentPath)

            try migrator.run(packageName: packageName, packagePath: targetDirectory)
            logger.info("Package \(packageName) was generated successfully. You can open the package via \(packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error)")
        }
    }
}
