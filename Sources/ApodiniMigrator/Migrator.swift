//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Logging
import PathKit

/// The ``MigrationContext`` holds any state for a ongoing migration.
public struct MigrationContext {
    /// This property holds the `Bundle.module` of the ``Migrator``.
    public var bundle: Bundle
    /// A logger instance for the given ``Migrator``.
    public var logger: Logger

    /// A dictionary of global placeholder values (e.g. ``Placeholder/packageName``).
    var placeholderValues: [Placeholder: String] = [:]
}


/// The ``Migrator`` protocol, any migrator must conform to.
public protocol Migrator {
    /// The `Bundle.module` to give access to the target specific resources.
    var bundle: Bundle { get }

    /// The swift `Logger` instance used within the whole migration process.
    static var logger: Logger { get }

    /// This result builder based property builds the whole directory structure
    /// of the client library and bootstraps all the migration processes.
    /// The path structure of every client library consists of a ``RootDirectory``
    /// at the root. The ``RootDirectory`` contains ``Sources``, ``Tests``
    /// and the ``SwiftPackageFile`` which all can be declared using the Library-DSL
    /// through the ``RootLibraryComponentBuilder``.
    @RootLibraryComponentBuilder
    var library: RootDirectory { get }

    /// This method is the entry point to the migration process.
    /// There is an implementation by default for every Migrator which uses
    /// the ``library`` to start up the migration processes.
    ///
    /// - Parameters:
    ///   - packageName: The Swift package name for the resulting library
    ///         (this string is placed under the ``Placeholder/packageName`` placeholder).
    ///   - packagePath: The path URL as a string to were the client library should be written.
    /// - Throws: Rethrows errors thrown by any ``LibraryComponent``s.
    func run(packageName: String, packagePath: String) throws
}

public extension Migrator {
    /// Default run implementation.
    func run(packageName: String, packagePath: String) throws {
        let name = packageName
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "/", with: "_")

        let path = Path(packagePath)
        var context = MigrationContext(bundle: bundle, logger: Self.logger)
        context.placeholderValues[.packageName] = name

        try library._handle(at: path, with: context)
    }
}
