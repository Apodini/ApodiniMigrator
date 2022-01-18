//
// Created by Andreas Bauer on 18.01.22.
//

import Foundation
import ArgumentParser

/// `ParseableArguments` which apply to the `generate` subcommand of all migrator types.
struct GlobalGenerateOptions: ParsableArguments {
    @Option(name: [NameSpecification.Element.customShort("n"), .long], help: "Name of the package")
    var packageName: String

    @Option(name: .shortAndLong, help: "Output path of the package (without package name)")
    var targetDirectory: String

    @Option(name: .shortAndLong, help: "Path where the base api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json")
    var documentPath: String
}
