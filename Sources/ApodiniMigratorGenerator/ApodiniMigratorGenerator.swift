//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import PathKit
import ApodiniMigrator

struct ApodiniMigratorGenerator {
    let packageName: String
    let packagePath: Path
    var document: Document
    let directories: ProjectDirectories
    
    var endpoints: [Endpoint] {
        document.endpoints
    }
    
    var metaData: MetaData {
        document.metaData
    }
    
    init(packageName: String, packagePath: String, documentPath: String) throws {
        self.packageName = packageName.trimmingCharacters(in: .whitespaces).without("/").upperFirst
        self.packagePath = Path(packagePath)
        document = try JSONDecoder().decode(Document.self, from: try Path(documentPath).read())
        document.dereference()
        self.directories = ProjectDirectories(packageName: packageName, packagePath: self.packagePath)
    }
    
    func buildProjectStructure() throws {
        try directories.build()
    }
}
