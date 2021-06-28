//
//  Compare.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ArgumentParser
import ApodiniMigratorGenerator

/// swift run migrator compare -o=/Users/eld/Desktop/delta_document.json -n=/Users/eld/Desktop/delta_document_updated.json -m=/Users/eld/Desktop
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
        guard Path(migrationGuidePath).isDirectory else {
            throw ValidationError("The specified path to persist the migration guide is not a directory")
        }
    }
    
    func run() throws {
        let migrator = ApodiniMigratorGenerator.Migrator.self
        let logger = migrator.logger

        logger.info("Starting generation of the migration guide...")
        do {
            let oldDocument = try Document.decode(from: Path(oldDocumentPath))
            let newDocument = try Document.decode(from: Path(newDocumentPath))
            let migrationGuideFileName = "migration_guide"
            let migrationGuide = MigrationGuide(for: oldDocument, rhs: newDocument)
            migrationGuide.write(at: Path(migrationGuidePath), fileName: migrationGuideFileName)
            logger.info("Migration guide was generated successfully at \(migrationGuidePath)/\(migrationGuideFileName).json.")
        } catch {
            logger.error("Migration guide generation failed with error: \(error)")
        }
    }
}
