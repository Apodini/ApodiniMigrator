//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MigratorAPI

/// An object that handles / triggers the migrated rendering of all endpoints of the client library
struct EndpointsMigrator: LibraryComposite {
    /// Suffix of endpoint files, e.g. `User+Endpoint.swift`
    static let fileSuffix = "+Endpoint" + .swift

    @SharedNodeReference
    var migratedEndpoints: [MigratedEndpoint]

    var endpointFiles: [EndpointFile]

    init(
        migratedEndpointsReference: SharedNodeReference<[MigratedEndpoint]>,
        allEndpoints: [Endpoint],
        endpointChanges: [Change]
    ) {
        self._migratedEndpoints = migratedEndpointsReference

        migratedEndpoints = []

        // Grouping the endpoints based on their nested response type
        let endpointGroups = allEndpoints.reduce(into: [String: Set<Endpoint>]()) { result, current in
            let nestedResponseType = current.response.nestedTypeString
            result[nestedResponseType, default: []].insert(current)
        }

        // Iterating through all endpoint groups, and rendering one migrated Endpoint file per group
        for group in endpointGroups {
            let endpoints = Array(group.value)
            let endpointIds = endpoints.identifiers()
            let groupChanges = endpointChanges.filter { endpointIds.contains($0.elementID) }
            let endpointFile = EndpointFile(
                migratedEndpointsReference: _migratedEndpoints,
                typeReference: group.key,
                endpoints: endpoints,
                changes: groupChanges
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
