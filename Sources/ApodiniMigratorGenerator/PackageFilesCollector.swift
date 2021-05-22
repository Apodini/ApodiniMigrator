//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

/// A typealias for a Dictionary with keys `DictionaryName` and values `[Path]`
fileprivate typealias DirectoryFiles = [DirectoryName: [Path]]

/// An object that collects all swift files inside packages created by ApodiniMigrator
public struct PackageFilesCollector {
    /// Project directories of the package
    private let projectDirectories: ProjectDirectories
    
    /// Files of the package grouped by directories
    private var directoryFiles: DirectoryFiles
    
    /// A list of all swift files contained in the package
    /// - Note: To get the path of specific file at a specific directory, make use of:
    /// `endpoint(name:)`, `model(name:)`, `networkingService()` and `testFile()` methods
    public private(set) var allSwiftFiles: [Path]
    
    /// Initializes `self` with the `packageName` and the string of the `packagePath`
    public init(packageName: String, packagePath: String) {
        directoryFiles = .init()
        allSwiftFiles = .init()
        
        projectDirectories = ProjectDirectories(packageName: packageName, packagePath: .init(packagePath))
        projectDirectories.assertDirectories()
        
        collectFiles()
    }
    
    /// Initializes `self` with the `packageName` and the `packagePath`
    public init(packageName: String, packagePath: Path) {
        self.init(packageName: packageName, packagePath: packagePath.string)
    }
    
    /// Collects all swift files of the packages and assigns to `allSwiftFiles`, additionally creates the directory files groups
    private mutating func collectFiles() {
        allSwiftFiles = projectDirectories.root.recursiveSwiftFiles()
        
        for file in allSwiftFiles {
            [DirectoryName.endpoints, .models, .networking, .tests].forEach { directory in
                if file.components.contains(directory.rawValue) {
                    if directoryFiles[directory] == nil {
                        directoryFiles[directory] = []
                    }
                    directoryFiles[directory]?.append(file)
                }
            }
        }
    }
    
    /// Returns that path of a file with `name` at a specified `directory`
    private func file(name: String, directory: DirectoryName) -> Path {
        let fileName = name.upperFirst + .swift
        if let filePath = directoryFiles[directory]?.first(where: { $0.lastComponent == fileName }) {
            return filePath
        }
        fatalError("\(fileName) couldn't be found in \(directory.rawValue)")
    }
    
    /// Returns the path of an endpoint file
    /// - Note: the passed name should correspond to the response type name of the endpoint, e.g. `UserResponse`,
    /// and the function returns the path of the file `UserResponse+Endpoint.swift`
    public func endpoint(name: String) -> Path {
        return file(name: (name + EndpointFileTemplate.fileSuffix).dropExtension(), directory: .endpoints)
    }
    
    /// Returns the path of a model with `name` from the `Models` directory
    /// - Note: the name to be passed can either be `User` or `User.swift`
    public func model(name: String) -> Path {
        file(name: name.dropExtension(), directory: .models)
    }
    
    /// Returns the path of the `NetworkingService.swift` file
    public func networkingService() -> Path {
        file(name: Template.networkingService.rawValue.upperFirst, directory: .networking)
    }
    
    /// Returns the path of the test file, e.g. `HelloWorldTests.swift`
    public func testFile() -> Path {
        file(name: projectDirectories.packageName + "Tests", directory: .tests)
    }
}

fileprivate extension String {
    func dropExtension() -> String {
        without("" + .swift)
    }
}
