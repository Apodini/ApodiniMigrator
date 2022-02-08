//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser
import RESTMigrator

struct Migrate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Migrate a client library using the base API document and a migration guide.",
        subcommands: [MigrateREST.self, MigrateGRPC.self]
    )
}
