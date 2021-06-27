//
//  main.swift
//  Generator
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import ArgumentParser
import ApodiniMigratorGenerator
import Foundation
import Logging

struct Generator: ParsableCommand {
    @Option(name: .shortAndLong, help: "Name of the package")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the delta_document.json file is located, e.g. /path/to/delta_document.json")
    var documentPath: String
    
    func run() throws {
        let logger = Migrator.logger
        
        logger.info("Starting generation of package \(packageName) at \(targetDirectory)")
        
        do {
            let generator = try Migrator(packageName: packageName, packagePath: targetDirectory, documentPath: documentPath, migrationGuide: .empty)
            try generator.migrate()
            logger.info("Package \(packageName) was generated successfully. You can open the package via \(targetDirectory)/\(packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error.localizedDescription)")
        }
    }
}

Generator.main()
