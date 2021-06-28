//
//  EndpointFile.swift
//  ApodiniMigratorGenerator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object that represents an `Type+Endpoint.swift` file in the client library
class EndpointFile: SwiftFile {
    /// Nested response type of endpoints that are grouped in the file, e.g `User` and `[User]` -> `User`
    let typeInformation: TypeInformation
    /// Kind of the file, always extension
    let kind: Kind = .extension
    /// Endpoints that are rendered in the file (same nested response type)
    let endpoints: [Endpoint]
    /// All changes of the migration guide that belong to the `endpoints`
    let changes: [Change]
    /// Array of endpoints that have been migrated from `EndpointMethodMigrator`, property gets appended with new migrated endpoints inside of `methodBody(for:)`
    var migratedEndpoints: [MigratedEndpoint] = []
    
    /// File comment that will be rendered for `self`
    var endpointFileComment: FileHeaderComment {
        .init(fileName: typeInformation.typeName.name + EndpointsMigrator.fileSuffix)
    }
    
    /// Initializes a new instance out of the same nested response type of `endpoints` and the `changes` that belong to those endpoints
    init(typeInformation: TypeInformation, endpoints: [Endpoint], changes: [Change]) {
        self.typeInformation = typeInformation
        self.endpoints = endpoints
        self.changes = changes
    }
    
    /// Renders the migrated method for `endpoint`
    private func methodBody(for endpoint: Endpoint) -> String {
        let endpointMigrator = EndpointMethodMigrator(endpoint, changes: changes.filter { $0.elementID == endpoint.deltaIdentifier })
        migratedEndpoints.append(endpointMigrator.migratedEndpoint)
        return endpointMigrator.render()
    }
    
    /// Renders the content of the file with all migrated endpoints
    func render() -> String {
        """
        \(endpointFileComment.render())
        
        \(Import(.foundation).render())
        
        \(MARKComment(.endpoints))
        \(kind.signature) \(typeInformation.typeName.name) {
        \(endpoints.map { methodBody(for: $0) }.joined(separator: .doubleLineBreak))
        }
        """
    }
}
