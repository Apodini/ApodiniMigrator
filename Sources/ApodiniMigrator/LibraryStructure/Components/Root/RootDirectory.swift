//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

public class RootDirectory: LibraryComposite {
    public var path: Name = .packageName

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
        guard let packageName = context.placeholderValues[.packageName] else {
            fatalError("PackageName not present")
        }

        let rootPath = path + packageName
        try? rootPath.delete()
        try rootPath.mkpath()
        
        context.logger.info("Starting library generation at: \(path.abbreviate())")

        packageSwift.targets.append(contentsOf: sources.targets.map { $0.targetDescription(with: context) })
        packageSwift.targets.append(contentsOf: tests?.targets.map { $0.targetDescription(with: context) } ?? [])
    }
}
