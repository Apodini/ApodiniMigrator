//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

/// A util property that serves to distribute changes to the elements that those belong to
struct ChangeFilter {
    /// Filtered changes where change element is an endpoint
    let endpointChanges: [Change]
    /// Filtered changes where change element is a model (either object or enum)
    let modelChanges: [Change]
    /// Filtered changes where change element is related with `NetworkingService`
    let networkingChanges: [Change]
    
    /// Initializes a new instance out of the migration guide
    init(_ migrationGuide: MigrationGuide) {
        let changes = migrationGuide.changes
        endpointChanges = changes.filter { $0.element.isEndpoint }
        modelChanges = changes.filter { [.enum, .object].contains($0.element.type) }
        networkingChanges = changes.filter { $0.element.isNetworking }
    }
    
    /// Filters added models out of the model changes
    func addedModels() -> [TypeInformation] {
        modelChanges.compactMap { change in
            if change.element.target == ObjectTarget.`self`.rawValue, let change = change as? AddChange, case let .element(anyCodable) = change.added {
                return anyCodable.typed(TypeInformation.self)
            }
            return nil
        }
    }
    
    /// Filteres added endpoints out of the endpoint changes
    func addedEndpoints() -> [Endpoint] {
        endpointChanges.compactMap { change in
            if change.element.target == EndpointTarget.`self`.rawValue, let change = change as? AddChange, case let .element(anyCodable) = change.added {
                return anyCodable.typed(Endpoint.self)
            }
            return nil
        }
    }
}
