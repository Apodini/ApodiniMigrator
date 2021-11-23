//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MigratorAPI

/// Represents the `API.swift` file of the client library
struct APIFile: SwiftFile, GeneratedFile {
    var fileName: [NameComponent] = ["API.swift"]

    /// TypeInformation is a caseless enum named `API`
    let typeInformation: TypeInformation = .enum(name: .init(name: "API"), rawValueType: nil, cases: [])
    /// Kind of the file
    let kind: Kind = .enum
    /// All migrated endpoints of the library
    @SharedNodeReference
    var endpoints: [MigratedEndpoint]

    /// Initializes a new instance out all the migrated endpoints of the library
    init(_ migratedEndpointsReference: SharedNodeReference<[MigratedEndpoint]>) {
        self._endpoints = migratedEndpointsReference
        endpoints.sorted()
    }

    /// Renders the wrapper method for the `migratedEndpoint`
    private func method(for migratedEndpoint: MigratedEndpoint) -> String {
        let endpoint = migratedEndpoint.endpoint
        let nestedType = endpoint.response.nestedTypeString
        var bodyInput = migratedEndpoint.parameters.map { "\($0.oldName): \($0.oldName)" }
        bodyInput.append(contentsOf: DefaultEndpointInput.allCases.map { $0.keyValue })
        let body =
        """
        \(migratedEndpoint.signature())
        \(nestedType).\(endpoint.deltaIdentifier)(\(String.lineBreak)\(bodyInput.joined(separator: ",\(String.lineBreak)"))\(String.lineBreak))
        }
        """
        return body
    }

    func render(with context: MigrationContext) -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())

        \(MARKComment(typeNameString))
        \(kind.signature) \(typeNameString) {}

        \(MARKComment(.endpoints))
        \(Kind.extension.signature) \(typeNameString) {
        \(endpoints.map { method(for: $0) }.joined(separator: .doubleLineBreak))
        }
        """
    }
}
