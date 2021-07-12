//
//  Migrator.swift
//  ApodiniMigratorCLI
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
