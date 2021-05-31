import ArgumentParser
import ApodiniMigratorGenerator

struct Generator: ParsableCommand {
    @Option(name: .shortAndLong, help: "Name of the package generated")
    var packageName: String
    
    @Option(name: .shortAndLong, help: "Output path of the package generated")
    var targetDirectory: String
    
    @Option(name: .shortAndLong, help: "Path where the document.json file is located")
    var documentPath: String
    
    func run() throws {
        let generator = try ApodiniMigratorGenerator(packageName: packageName, packagePath: targetDirectory, documentPath: documentPath)
        
        try generator.build()
    }
}

Generator.main()
