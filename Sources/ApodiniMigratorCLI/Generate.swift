//
//  Generate.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ArgumentParser
import ApodiniMigratorGenerator

/// swift run migrator generate -d=/Users/eld/Desktop/delta_document.json -p=ClientLibrary -t=/Users/eld/Desktop
struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to generate a client library out of a delta document"
    )
    
    @Option(name: .shortAndLong, help: "Name of the package")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the delta_document.json file is located, e.g. /path/to/delta_document.json")
    var documentPath: String
    
    func run() throws {
        let migrator = ApodiniMigratorGenerator.Migrator.self
        let logger = migrator.logger
        
        logger.info("Starting generation of package \(packageName) at \(targetDirectory)")
        
        do {
            let generator = try migrator.init(packageName: packageName, packagePath: targetDirectory, documentPath: documentPath, migrationGuide: .empty)
            try generator.migrate()
            logger.info("Package \(packageName) was generated successfully. You can open the package via \(targetDirectory)/\(packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error)")
        }
    }
}
