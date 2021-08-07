//
//  EndpointsMigrator.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object that handles / triggeres the migrated rendering of all endpoints of the client library
struct EndpointsMigrator {
    /// Suffix of endpoint files, e.g. `User+Endpoint.swift`
    static let fileSuffix = "+Endpoint" + .swift
    /// Path to the `Endpoints` directory of the client library
    let endpointsPath: Path
    /// Path to target directory of the client library where the `API.swift` file gets rendered
    let apiFilePath: Path
    /// All old and added endpoints
    let allEndpoints: [Endpoint]
    /// All changes that belong to endpoints
    let endpointChanges: [Change]
    
    /// Triggers the migrated rendering of all endpoints of the client library and rendering of the `API.swift` file
    func migrate() throws {
        // Grouping the endpoints based on their nested response type
        let endpointGroups = allEndpoints.reduce(into: [TypeInformation: Set<Endpoint>]()) { result, current in
            let nestedResponseType = current.response.nestedType
            result[nestedResponseType, default: []].insert(current)
        }
        
        var migratedEndpoints: [MigratedEndpoint] = []
        
        // Iterating through all endpoint groups, and rendering one migrated Endpoint file per group
        for group in endpointGroups {
            let endpoints = Array(group.value)
            let endpointIds = endpoints.identifiers()
            let groupChanges = endpointChanges.filter { endpointIds.contains($0.elementID) }
            let fileName = group.key.typeName.name + Self.fileSuffix
            let endpointFile = EndpointFile(typeInformation: group.key, endpoints: endpoints, changes: groupChanges)
            // triggeres migration of endpoints, rendering of file, and stores the migratedEndpoints in `endpointFile.migratedEndpoints`
            try endpointFile.write(at: endpointsPath, alternativeFileName: fileName)
            migratedEndpoints.append(contentsOf: endpointFile.migratedEndpoints)
        }
        // Renders the api file from the migratedEndpoints collected in the for loop
        let apiFile = APIFile(migratedEndpoints)
        try apiFile.write(at: apiFilePath)
    }
}
