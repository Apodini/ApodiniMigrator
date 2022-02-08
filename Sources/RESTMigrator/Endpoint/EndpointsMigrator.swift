//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// An object that handles / triggers the migrated rendering of all endpoints of the client library
struct EndpointsMigrator: LibraryComposite {
    @SharedNodeReference
    var migratedEndpoints: [MigratedEndpoint]

    var endpointFiles: [EndpointFile] = []

    init(
        migratedEndpointsReference: SharedNodeReference<[MigratedEndpoint]>,
        document baseDocument: APIDocument,
        migrationGuide: MigrationGuide
    ) {
        self._migratedEndpoints = migratedEndpointsReference
        self.migratedEndpoints = []

        let baseEndpoints = baseDocument.endpoints
        let addedModels = migrationGuide.endpointChanges
            .compactMap { $0.modeledAdditionChange }
            .map { $0.added }

        let allEndpoints = baseEndpoints + addedModels

        // Grouping the endpoints based on their nested response type
        let groupedEndpoints = allEndpoints.reduce(into: [String: [Endpoint]]()) { result, current in
            result[current.response.nestedTypeString, default: []]
                .append(current)
        }

        // Iterating through all endpoint groups, and rendering one migrated Endpoint file per group
        for (key, endpoints) in groupedEndpoints {
            let endpointIds = endpoints.identifiers()
            let changes = migrationGuide.endpointChanges
                .filter { endpointIds.contains($0.id) }

            let endpointFile = EndpointFile(
                migratedEndpointsReference: _migratedEndpoints,
                typeInformation: .reference(key),
                endpoints: endpoints,
                changes: changes
            )
            endpointFiles.append(endpointFile)
        }
    }

    var content: [LibraryComponent] {
        for file in endpointFiles {
            file
        }
    }
}
