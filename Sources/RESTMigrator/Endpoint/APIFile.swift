//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents the `API.swift` file of the client library
struct APIFile: GeneratedFile {
    var fileName: Name = "API.swift"

    private let typeName = "API"

    /// All migrated endpoints of the library
    @SharedNodeReference
    var endpoints: [MigratedEndpoint]

    /// Initializes a new instance out all the migrated endpoints of the library
    init(_ migratedEndpointsReference: SharedNodeReference<[MigratedEndpoint]>) {
        self._endpoints = migratedEndpointsReference
        endpoints.sort()
    }

    var renderableContent: String {
        FileHeaderComment()

        Import(.foundation)
        ""

        MARKComment(typeName)
        "\(Kind.enum.signature) \(typeName) {}"
        ""

        MARKComment(.endpoints)
        "\(Kind.extension.signature) \(typeName) {"

        Indent {
            for migratedEndpoint in endpoints {
                let endpoint = migratedEndpoint.endpoint
                let nestedType = endpoint.response.nestedTypeString
                var bodyInput = migratedEndpoint.parameters.map { "\($0.oldName): \($0.oldName)" }
                bodyInput.append(contentsOf: DefaultEndpointInput.allCases.map { $0.keyValue })

                migratedEndpoint.signature

                Indent {
                    "\(nestedType).\(endpoint.deltaIdentifier.swiftSanitizedName.lowerFirst)("
                    Indent {
                        Joined(by: ",") {
                            bodyInput
                        }
                    }
                    ")"
                }
                "}"
            }
        }

        "}"
    }
}
