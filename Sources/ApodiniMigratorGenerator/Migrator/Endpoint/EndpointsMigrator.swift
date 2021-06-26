//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

struct EndpointsMigrator {
    static let fileSuffix = "+Endpoint" + .swift
    
    let endpointsPath: Path
    let webServicePath: Path
    let allEndpoints: [Endpoint]
    let endpointChanges: [Change]
    
    func migrate() throws {
        let endpointGroups = allEndpoints.reduce(into: [TypeInformation: Set<Endpoint>]()) { result, current in
            let nestedResponseType = current.response.nestedType
            result[nestedResponseType, default: []].insert(current)
        }
        
        var webServiceEndpoints: [WebServiceEndpoint] = []
        for group in endpointGroups {
            let endpoints = Array(group.value)
            let endpointIds = endpoints.identifiers()
            let groupChanges = endpointChanges.filter { endpointIds.contains($0.elementID) }
            let fileName = group.key.typeName.name + Self.fileSuffix
            let endpointFile = EndpointFile(typeInformation: group.key, endpoints: endpoints, changes: groupChanges)
            try endpointFile.write(at: endpointsPath, alternativeFileName: fileName)
            webServiceEndpoints.append(contentsOf: endpointFile.webServiceEndpoints)
        }
        
        let webServiceFile = WebServiceFileTemplate2(webServiceEndpoints)
        try (webServicePath + WebServiceFileTemplate2.filePath).write(webServiceFile.render().indentationFormatted())
    }
}
