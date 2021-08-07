//
//  Compare.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ArgumentParser
import ApodiniMigrator

struct Compare: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to compare API documents and automatically generate a migration guide between two versions"
    )
    
    @Option(name: .shortAndLong, help: "Path to API document of the old version, e.g. /path/to/api_v1.0.0.json")
    var oldDocumentPath: String
    
    @Option(name: .shortAndLong, help: "Path to API document of the new version, e.g. /path/to/api_v1.2.0.yaml")
    var newDocumentPath: String
    
    @Option(name: .shortAndLong, help: "Path to a directoy where the migration guide should be persisted, e.g. /path/to/directory")
    var migrationGuidePath: String
    
    @Option(name: .shortAndLong, help: "Output format of the migration guide, either JSON or YAML. JSON by default")
    var format: OutputFormat = .json
    
    func validate() throws {
        guard migrationGuidePath.asPath.isDirectory else {
            throw ValidationError("The specified path to persist the migration guide is not a directory")
        }
    }
    
    func run() throws {
        let migrator = ApodiniMigrator.Migrator.self
        let logger = migrator.logger

        logger.info("Starting generation of the migration guide...")
        do {
            let migrationGuideFileName = "migration_guide"
            let migrationGuide = try MigrationGuide.from(oldDocumentPath.asPath, newDocumentPath.asPath)
            try migrationGuide.write(at: migrationGuidePath.asPath, outputFormat: format, fileName: migrationGuideFileName)
            logger.info("\(migrationGuideFileName).\(format) was generated successfully.")
        } catch {
            logger.error("Migration guide generation failed with error: \(error)")
        }
    }
}

// MARK: - OutputFormat + ExpressibleByArgument
extension OutputFormat: ExpressibleByArgument {}
