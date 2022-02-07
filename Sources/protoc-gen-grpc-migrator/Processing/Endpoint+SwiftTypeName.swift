//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

extension Endpoint {
    var swiftTypeName: String {
        handlerName.buildName(
            printTargetName: true,
            componentSeparator: ".",
            genericsStart: "<",
            genericsSeparator: ",",
            genericsDelimiter: ">"
        )
    }

    func updatedSwiftTypeName(considering migrationGuide: MigrationGuide) -> String {
        updatedIdentifier(for: TypeName.self, considering: migrationGuide)
            .buildName(
                printTargetName: true,
                componentSeparator: ".",
                genericsStart: "<",
                genericsSeparator: ",",
                genericsDelimiter: ">"
            )
    }
}
