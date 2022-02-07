//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser

/// `ParseableArguments` which apply to the `generate` subcommand of all migrator types.
struct GlobalGenerateOptions: ParsableArguments {
    @Option(name: [NameSpecification.Element.customShort("n"), .long], help: "Name of the package")
    var packageName: String

    @Option(name: .shortAndLong, help: "Output path of the package (without package name)", completion: .directory)
    var targetDirectory: String

    @Option(
        name: .shortAndLong,
        help: "Path where the base api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json",
        completion: .file(extensions: ["json", "yaml"])
    )
    var documentPath: String
}
