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
            if lhs.restResponse == rhs.restResponse {
                return lhs.deltaIdentifier < rhs.deltaIdentifier
            }
            return lhs.restResponse.typeName.name < rhs.restResponse.typeName.name
        }
    }
    
    
    private func method(for endpoint: Endpoint) -> String {
        let responseName = endpoint.restResponse.typeName.name
        let methodParameters = endpoint.signatureParameters
            .map { "\($0.parameterName.value): \($0.parameterName.value)" }
            .joined(separator: ", ")
        let methodInputString = endpoint.methodInputString()
        let methodName = endpoint.deltaIdentifier
        let body =
        """
        \(EndpointComment(endpoint))
        static func \(methodName)(\(methodInputString)) -> ApodiniPublisher<\(responseName)> {
        \(responseName).\(methodName)(\(methodParameters))
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