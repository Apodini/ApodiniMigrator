//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

public struct ChangeFilter {
    public let migrationGuide: MigrationGuide
    public var allChanges: [Change] {
        migrationGuide.changes
    }
    public let endpointChanges: [Change]
    public let modelChanges: [Change]
    public let networkingChanges: [Change]
    
    
    init(_ migrationGuide: MigrationGuide) {
        self.migrationGuide = migrationGuide
        let changes = migrationGuide.changes
        endpointChanges = changes.filter { $0.element.isEndpoint }
        modelChanges = changes.filter { [.enum, .object].contains($0.element.type)}
        networkingChanges = changes.filter { $0.element.isNetworking }
    }
    
    public func addedModels() -> [TypeInformation] {
        let addedChanges = modelChanges.filter { change in
            change.type == .addition && change.element.target == ObjectTarget.`self`.rawValue
        } as? [AddChange] ?? []
        
        return addedChanges.compactMap { change in
            if case let .element(typeInformation) = change.added {
                return typeInformation.typed(TypeInformation.self)
            }
            return nil
        }.fileRenderableTypes()
    }
    
    public func addedEndpoints() -> [Endpoint] {
        let addedChanges = endpointChanges.filter { change in
            change.type == .addition && change.element.target == EndpointTarget.`self`.rawValue
        } as? [AddChange] ?? []
        
        return addedChanges.compactMap { change in
            if case let .element(endpoint) = change.added {
                return endpoint.typed(Endpoint.self)
            }
            return nil
        }
    }
    
    public func deletedEndpointIDs() -> [DeltaIdentifier] {
        let deleteChange = endpointChanges.filter { change in
            change.type == .deletion && change.element.target == EndpointTarget.`self`.rawValue
        } as? [DeleteChange] ?? []
        
        return deleteChange.compactMap { change in
            if case let .elementID(id) = change.deleted {
                return id
            }
            return nil
        }
    }
}
