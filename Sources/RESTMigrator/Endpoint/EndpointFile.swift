//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import ApodiniDocumentExport

/// An object that represents an `Type+Endpoint.swift` file in the client library
class EndpointFile: GeneratedFile {
    /// Suffix of endpoint files, e.g. `User+Endpoint.swift`
    static let fileSuffix = "+Endpoint" + .swift

    let fileName: Name

    @SharedNodeReference
    var migratedEndpoints: [MigratedEndpoint]

    /// Nested response type of endpoints that are grouped in the file, e.g `User` and `[User]` -> `User`
    let typeInformation: TypeInformation
    /// Kind of the file, always extension
    let kind: Kind = .extension
    /// Endpoints that are rendered in the file (same nested response type)
    private let endpoints: [Endpoint]
    /// All changes of the migration guide that belong to the `endpoints`
    private let changes: [EndpointChange]
    /// Imports of the file
    private var imports = Import(.foundation)
    
    /// Initializes a new instance out of the same nested response type of `endpoints` and the `changes` that belong to those endpoints
    init(
        migratedEndpointsReference: SharedNodeReference<[MigratedEndpoint]>,
        typeInformation: TypeInformation,
        endpoints: [Endpoint],
        changes: [EndpointChange]
    ) {
        _migratedEndpoints = migratedEndpointsReference
        self.fileName = "\(typeInformation.unsafeTypeString)\(EndpointFile.fileSuffix)"
        self.typeInformation = typeInformation

        self.endpoints = endpoints.sorted { lhs, rhs in
            if lhs.response.unsafeTypeString == rhs.response.unsafeTypeString {
                return lhs.deltaIdentifier < rhs.deltaIdentifier
            }
            return lhs.response.unsafeTypeString < rhs.response.unsafeTypeString
        }
        self.changes = changes

        if changes.contains(where: { $0.type == .removal }) {
            imports.insert(.combine)
        }
    }

    var renderableContent: String {
        FileHeaderComment()

        imports
        ""

        MARKComment(.endpoints)
        "\(kind.signature) \(typeInformation.unsafeFileNaming) {"

        Indent {
            var first = true
            for endpoint in endpoints {
                if !first {
                    ""
                    ""
                } else {
                    first = false
                }

                let endpointMigrator = EndpointMethodMigrator(
                    endpoint,
                    changes: changes.of(base: endpoint)
                )
                migratedEndpoints.append(endpointMigrator.migratedEndpoint)

                // rendering the method body
                endpointMigrator
            }
        }

        "}"
    }
}
