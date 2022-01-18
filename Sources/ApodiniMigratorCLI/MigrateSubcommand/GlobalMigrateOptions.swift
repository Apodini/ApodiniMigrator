//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser

/// `ParseableArguments` which apply to the `migrate` subcommand of all migrator types.
@dynamicMemberLookup
struct GlobalMigrateOptions: ParsableArguments {
    @OptionGroup
    var generateOptions: GlobalGenerateOptions

    @Option(name: .shortAndLong, help: "Path where the migration guide is located, e.g. /path/to/migration_guide.json")
    var migrationGuidePath: String

    subscript<T>(dynamicMember member: KeyPath<GlobalGenerateOptions, T>) -> T {
        generateOptions[keyPath: member]
    }
}
