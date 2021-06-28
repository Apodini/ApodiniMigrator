//
//  Migrate.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ArgumentParser
import ApodiniMigratorGenerator

/// swift run migrator migrate -t=/Users/eld/Desktop -d=/Users/eld/Desktop/delta_document.json -m=/Users/eld/Desktop/migration_guide.json -p=MigratorCLI
struct Migrate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to migrate a client library out of a delta document and a migration guide"
    )
    
    @Option(name: .shortAndLong, help: "Name of the package")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the delta document of the old version file is located, e.g. /path/to/delta_document.json")
    var documentPath: String
    
    @Option(name: .shortAndLong, help: "Path where the migration guide is located, e.g. /path/to/migration_guide.json")
    var migrationGuidePath: String
    
    func run() throws {
        let migrator = ApodiniMigratorGenerator.Migrator.self
        let logger = migrator.logger
        
        logger.info("Starting migration of package \(packageName) at \(targetDirectory)")
        
        do {
            let migrationGuide = try MigrationGuide.decode(from: Path(migrationGuidePath))
            let generator = try migrator.init(packageName: packageName, packagePath: targetDirectory, documentPath: documentPath, migrationGuide: migrationGuide)
            try generator.migrate()
            logger.info("Package \(packageName) was migrated successfully. You can open the package via \(targetDirectory)/\(packageName)/Package.swift")
        } catch {
            logger.error("Package migration failed with error: \(error)")
        }
    }
}
