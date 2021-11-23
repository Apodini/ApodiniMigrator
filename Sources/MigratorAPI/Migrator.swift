//
// Created by Andreas Bauer on 14.11.21.
//

import Foundation
import Logging
import PathKit

// TODO how to extend? Delegation or overwriting?


// TODO would love a DSL based Migrator structure (based on directories)
//  => entry is either
//     empty directory
//     Files From Template
//     Some "complex" Migrator

public struct MigrationContext {
    public var bundle: Bundle

    var placeholderValues: [Placeholder: String] = [:]
}

public protocol Migrator {
    var bundle: Bundle { get } // TODO ability to access template directory!

    // TODO rename library structure?
    @RootLibraryComponentBuilder
    var library: RootDirectory { get }

    func run(packageName: String, packagePath: String) throws
}

public extension Migrator {
    func run(packageName: String, packagePath: String) throws {
        // TODO upperfirst name?
        let name = packageName
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "/", with: "_")

        let path = Path(packagePath)
        var context = MigrationContext(bundle: bundle)
        context.placeholderValues[GlobalPlaceholder.$packageName] = name

        try library._handle(at: path, with: context)
    }
}

// TODO move
public enum GlobalPlaceholder {
    @PlaceholderDefinition(wrappedValue: Placeholder("PACKAGE_NAME"))
    public static var packageName
}

public struct Migrator2 {
    public static let logger: Logger = {
        .init(label: "org.apodini.migrator")
    }()

    /// The Swift Package name which is to be generated/migrated
    private let packageName: String
    /// Path to the package TODO what is included and what not?
    private let packagePath: Path

    // TODO some sort of API document?

    /// Logger of the migrator
    private let logger: Logger
    // TODO individual sub Migrator (endpoints, models, networking)

    // TODO allModels

    // TODO scripts, and jsonValues??, objectJSONs?

    // TODO encoderConfiguration?
}
