//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A util object that serves to distribute changes to the elements that those belong to
public struct ChangeFilter {
    /// Filtered changes where change element is an endpoint
    public let endpointChanges: [Change]
    /// Filtered changes where change element is a model (either object or enum)
    public let modelChanges: [Change]
    /// Filtered changes where change element is related with `NetworkingService`
    public let networkingChanges: [Change]
    
    /// Initializes a new instance out of the migration guide
    public init(_ migrationGuide: MigrationGuide) {
        let changes = migrationGuide.changes
        endpointChanges = changes.filter { $0.element.isEndpoint }
        modelChanges = changes.filter { $0.element.isModel }
        networkingChanges = changes.filter { $0.element.isNetworking }
    }
    
    /// Filters added models out of the model changes
    public func addedModels() -> [TypeInformation] {
        modelChanges.compactMap { change in
            if
                change.element.target == ObjectTarget.`self`.rawValue,
                let change = change as? AddChange,
                case let .element(anyCodable) = change.added
            {
                return anyCodable.typed(TypeInformation.self)
            }
            return nil
        }
    }
    
    /// Filteres added endpoints out of the endpoint changes
    public func addedEndpoints() -> [Endpoint] {
        endpointChanges.compactMap { change in
            if
                change.element.target == EndpointTarget.`self`.rawValue,
                let change = change as? AddChange,
                case let .element(anyCodable) = change.added
            {
                return anyCodable.typed(Endpoint.self)
            }
            return nil
        }
    }
}
