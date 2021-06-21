//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

public struct ChangeFilter {
    public let migrationGuide: MigrationGuide
    public let allChanges: [Change]
    public let endpointChanges: [Change]
    public let modelChanges: [Change]
    public let networkingChanges: [Change]
    
    
    init(_ migrationGuide: MigrationGuide) {
        self.migrationGuide = migrationGuide
        allChanges = migrationGuide.changes
        endpointChanges = allChanges.filter { $0.element.isEndpoint }
        modelChanges = allChanges.filter { [.enum, .object].contains($0.element.type)}
        networkingChanges = allChanges.filter { $0.element.isNetworking }
    }
    
    public func addedModels() -> [TypeInformation] {
        let addedChanges = modelChanges.filter { change in
            change.type == .addition && change.element.target == ObjectTarget.`self`.rawValue
        } as? [AddChange] ?? []
        
        return addedChanges.map { change in
            if case let .element(typeInformation) = change.added {
                return typeInformation.typed(TypeInformation.self)
            }
            fatalError("Encountered a model AddChange that did not encode the type information in its element")
        }
    }
    
    public func deletedModelIDs() -> [DeltaIdentifier] {
        let deletedChanges = modelChanges.filter { change in
            change.type == .deletion && change.element.target == ObjectTarget.`self`.rawValue
        } as? [DeleteChange] ?? []
        
        return deletedChanges.map { change in
            if case let .elementID(id) = change.deleted {
                return id
            }
            fatalError("Encountered a model DeleteChange that did not encode the id of type information in its element")
        }
    }
    
    public func addedEndpoints() -> [Endpoint] {
        let addedChanges = endpointChanges.filter { change in
            change.type == .addition && change.element.target == EndpointTarget.`self`.rawValue
        } as? [AddChange] ?? []
        
        return addedChanges.map { change in
            if case let .element(endpoint) = change.added {
                return endpoint.typed(Endpoint.self)
            }
            fatalError("Encountered an endpoint AddChange that did not encode the endpoint in its element")
        }
    }
    
    public func deletedEndpointIDs() -> [DeltaIdentifier] {
        let deleteChange = endpointChanges.filter { change in
            change.type == .deletion && change.element.target == EndpointTarget.`self`.rawValue
        } as? [DeleteChange] ?? []
        
        return deleteChange.map { change in
            if case let .elementID(id) = change.deleted {
                return id
            }
            fatalError("Encountered an endpoint DeleteChange that did not encode the id of its element")
        }
    }
}
