//
//  Migrate.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ArgumentParser
import ApodiniMigrator

struct Migrate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to migrate a client library out of an API document and a migration guide"
    )
    
    @Option(name: .shortAndLong, help: "Name of the package")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the API document of the old version file is located, e.g. /path/to/api_v1.2.3.yaml")
    var documentPath: String
    
    @Option(name: .shortAndLong, help: "Path where the migration guide is located, e.g. /path/to/migration_guide.json")
    var migrationGuidePath: String
    
    func run() throws {
        let migratorType = ApodiniMigrator.Migrator.self
        let logger = migratorType.logger
        
        logger.info("Starting migration of package \(packageName)")
        
        do {
            let migrationGuide = try MigrationGuide.decode(from: migrationGuidePath.asPath)
            let migrator = try migratorType.init(
                packageName: packageName,
                packagePath: targetDirectory,
                documentPath: documentPath,
                migrationGuide: migrationGuide
            )
            try migrator.migrate()
            logger.info("Package \(packageName) was migrated successfully. You can open the package via \(packageName)/Package.swift")
        } catch {
            logger.error("Package migration failed with error: \(error)")
        }
    }
}
