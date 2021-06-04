//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

public struct WebServiceFileTemplate: Renderable {
    public static let fileName = "WebService"
    let endpoints: [Endpoint]
    
    public init(_ endpoints: [Endpoint]) {
        self.endpoints = endpoints.sorted { lhs, rhs in
            if lhs.response == rhs.response {
                return lhs.deltaIdentifier < rhs.deltaIdentifier
            }
            return lhs.response.typeName.name < rhs.response.typeName.name
        }
    }
    
    
    private func method(for endpoint: Endpoint) -> String {
        let nestedType = endpoint.response.nestedType.typeName.name
        let typeString = endpoint.response.typeString
        var methodParameters = endpoint.signatureParameters
            .map { "\($0.name): \($0.name)" }
            
        if let authorization = endpoint.authorization {
            methodParameters.append("\(authorization.name): \(authorization.name)")
        }
        
        let methodInputString = endpoint.methodInputString()
        let methodName = endpoint.deltaIdentifier
        let body =
        """
        \(EndpointComment(endpoint))
        public static func \(methodName)(\(methodInputString)) -> ApodiniPublisher<\(typeString)> {
        \(nestedType).\(methodName)(\(methodParameters.joined(separator: ", ")))
        }
        """
        return body
    }
    
    public func render() -> String {
        """
        \(FileHeaderComment(fileName: "\(Self.fileName)" + .swift).render())

        \(Import(.foundation).render())

        \(MARKComment(.endpoints))
        public \(Kind.enum.rawValue) \(Self.fileName) {
        \(endpoints.map { method(for: $0) }.joined(separator: .doubleLineBreak))
        }
        """
    }
}
