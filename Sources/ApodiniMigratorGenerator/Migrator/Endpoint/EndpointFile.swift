//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

class EndpointFile: SwiftFileTemplate {
    var typeInformation: TypeInformation
    var endpoints: [Endpoint]
    var changes: [Change]
    var webServiceEndpoints: [WebServiceEndpoint] = []
    var kind: Kind
    
    var endpointFileComment: FileHeaderComment {
        .init(fileName: typeInformation.typeName.name + EndpointsMigrator.fileSuffix)
    }
    
    init(typeInformation: TypeInformation, endpoints: [Endpoint], changes: [Change], kind: Kind) {
        self.typeInformation = typeInformation
        self.endpoints = endpoints
        self.changes = changes
        self.kind = kind
    }
    
    private func methodBody(for endpoint: Endpoint) -> String {
        let endpointMigrator = EndpointMethodMigrator(endpoint, changes: changes)
        webServiceEndpoints.append(endpointMigrator.webServiceEndpoint)
        return endpointMigrator.render()
    }
    
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
