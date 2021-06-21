//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

struct EndpointsMigrator {
    
    let endpointsPath: Path
    let oldEndpoints: [Endpoint]
    let addedEndpoints: [Endpoint]
    let deletedEndpointIDs: [DeltaIdentifier]
    let endpointChanges: [Change]
    
    func build() throws {
        
    }
}
