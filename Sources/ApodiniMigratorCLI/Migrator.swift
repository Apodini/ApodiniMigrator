//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser

@main
struct Migrator: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to automatically generate migration guides and migrated client libraries",
        subcommands: [Compare.self, Migrate.self, Generate.self],
        defaultSubcommand: Compare.self
    )
}
