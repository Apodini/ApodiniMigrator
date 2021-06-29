//
//  Compare.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ArgumentParser
import ApodiniMigrator

struct Compare: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to compare delta documents and automatically generate a migration guide between two versions"
    )
    
    @Option(name: .shortAndLong, help: "Path to delta document of the old version, e.g. /path/to/delta_document.json")
    var oldDocumentPath: String
    
    @Option(name: .shortAndLong, help: "Path to delta document of the new version, e.g. /path/to/delta_document_updated.json")
    var newDocumentPath: String
    
    @Option(name: .shortAndLong, help: "Path to a directoy where the migration guide should be persisted, e.g. /path/to/directory")
    var migrationGuidePath: String
    
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
            let oldDocument = try Document.decode(from: oldDocumentPath.asPath)
            let newDocument = try Document.decode(from: newDocumentPath.asPath)
            let migrationGuideFileName = "migration_guide"
            let migrationGuide = MigrationGuide(for: oldDocument, rhs: newDocument)
            migrationGuide.write(at: migrationGuidePath.asPath, fileName: migrationGuideFileName)
            logger.info("Migration guide was generated successfully at \(migrationGuidePath)/\(migrationGuideFileName).json.")
        } catch {
            logger.error("Migration guide generation failed with error: \(error)")
        }
    }
}
