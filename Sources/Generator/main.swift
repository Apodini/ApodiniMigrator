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
        let logger = ApodiniMigratorGenerator.logger
        
        logger.info("Starting generation of package \(packageName) at \(targetDirectory)")
        
        do {
            let generator = try ApodiniMigratorGenerator(packageName: packageName, packagePath: targetDirectory, documentPath: documentPath)
            try generator.build()
            logger.info("Package \(packageName) was generated successfully. You can open the package via \(targetDirectory)/\(packageName)/Package.swift")
        } catch {
            logger.error("Package generation failed with error: \(error.localizedDescription)")
        }
    }
}

Generator.main()
