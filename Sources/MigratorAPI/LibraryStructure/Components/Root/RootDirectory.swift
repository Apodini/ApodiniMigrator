//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public class RootDirectory: DirectoryProtocol {
    public var path: [NameComponent] = [GlobalPlaceholder.$packageName]

    public var content: [LibraryComponent]

    var sources: Sources
    var tests: Tests?

    var packageSwift: SwiftPackageFile

    init(content: [LibraryComponent]) {
        var foundSources: Sources?
        var foundTests: Tests?
        var foundPackage: SwiftPackageFile?

        for content in content {
            if let sources = content as? Sources {
                precondition(foundSources == nil, "Encountered sources twice!")
                foundSources = sources
            } else if let tests = content as? Tests {
                precondition(foundTests == nil, "Encountered tests twice!")
                foundTests = tests
            } else if let package = content as? SwiftPackageFile {
                precondition(foundPackage == nil, "Encountered Package.swift twice!")
                foundPackage = package
            }
        }


        self.content = content

        guard
            let sources = foundSources,
            let packageSwift = foundPackage else {
            preconditionFailure("Every library needs sources and a Package.swift!")
        }

        self.sources = sources
        self.tests = foundTests
        self.packageSwift = packageSwift
    }

    public func handle(at path: Path, with context: MigrationContext) throws {
        guard let packageName = context.placeholderValues[GlobalPlaceholder.$packageName] else {
            fatalError("PackageName not present")
        }

        let rootPath = path + packageName
        try? rootPath.delete() // TODO dangerous operation (failsafes for accidential deleations?)
        try rootPath.mkpath()

        packageSwift.targets.append(contentsOf: sources.targets.map({ $0.targetDescription(with: context) }))
        packageSwift.targets.append(contentsOf: tests?.targets.map({ $0.targetDescription(with: context) }) ?? [])
    }
}


