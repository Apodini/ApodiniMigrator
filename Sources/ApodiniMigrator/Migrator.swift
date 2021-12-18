//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Logging
import PathKit

public struct MigrationContext {
    public var bundle: Bundle
    public var logger: Logger

    var placeholderValues: [Placeholder: String] = [:]
}


public protocol Migrator {
    var bundle: Bundle { get }

    static var logger: Logger { get }

    @RootLibraryComponentBuilder
    var library: RootDirectory { get }

    func run(packageName: String, packagePath: String) throws
}

public extension Migrator {
    func run(packageName: String, packagePath: String) throws {
        let name = packageName
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "/", with: "_")

        let path = Path(packagePath)
        var context = MigrationContext(bundle: bundle, logger: Self.logger)
        context.placeholderValues[GlobalPlaceholder.$packageName] = name

        try library._handle(at: path, with: context)
    }
}


// TODO first of all "Move", but also rethink the whole thing, not really happy how it turned out tbh
public enum GlobalPlaceholder {
    @PlaceholderDefinition(wrappedValue: Placeholder("PACKAGE_NAME"))
    public static var packageName
}
