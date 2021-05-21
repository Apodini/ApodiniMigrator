//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation


public struct EndpointFileTemplate: SwiftFileTemplate {
    var typeInformation: TypeInformation
    var kind: Kind
    public var endpoints: [Endpoint]
    
    var stringTypeName: String {
        typeInformation.typeName.name
    }
    
    var endpointFileComment: FileHeaderComment {
        .init(fileName: stringTypeName + "+Endpoint.swift")
    }
    
    init(_ typeInformation: TypeInformation, kind: Kind) throws {
        self.typeInformation = typeInformation
        self.kind = .extension
        self.endpoints = []
    }
    
    public init(with response: TypeInformation, endpoints: [Endpoint]) throws {
        let responses = endpoints.map { $0.restResponse }.unique()
        guard responses.count == 1, responses.first == response else {
            fatalError("""
                Endpoints have different responses and can't be rendered in the same extension:
                \(responses.map { $0.typeName.name }.joined(separator: ", "))
                """)
        }
        
        try self.init(response, kind: .extension)
        self.endpoints = endpoints.sorted { $0.deltaIdentifier.rawValue < $1.deltaIdentifier.rawValue }
    }
    
    
    private func endpointMethod(endpoint: Endpoint) -> String {
        let path = endpoint.absolutePath.value.replacingOccurrences(of: "{", with: "\\(").replacingOccurrences(of: "}", with: ")")
        let queryParametersString: String = {
            guard !endpoint.queryParameters.isEmpty else {
                return ""
            }
            let string =
            """
            var parameters: Parameters = [:]
            \(endpoint.queryParameters.map { "parameters.set(\($0.parameterName.value), forKey: \($0.parameterName.value.asString))" }.withBreakingLines())
            """
            return string + .doubleLineBreak
        }()
        
        let body =
        """
        \(EndpointComment("API call for \(endpoint.handlerName.value) at: \(endpoint.absolutePath.value)"))
        static func \(endpoint.deltaIdentifier.rawValue)(\(endpoint.signatureParameters.methodSignature())) -> ApodiniPublisher<\(stringTypeName)> {
        \(queryParametersString)var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        \(endpoint.errors.map { "errors.addError(\($0.code), message: \($0.message.asString))" }.withBreakingLines())

        let handler = Handler<\(stringTypeName)>(
        path: \(path.asString),
        httpMethod: .\(endpoint.operation.asHTTPMethodString),
        parameters: \(queryParametersString.isEmpty ? "[:]" : "parameters"),
        headers: headers,
        content: \(endpoint.contentParameterString),
        authorization: nil,
        errors: errors
        )

        return NetworkingService.trigger(handler)
        }
        """
        return body
    }
    
    
    public func render() -> String {
        """
        \(endpointFileComment.render())

        \(Import(.foundation).render())

        \(MARKComment(.endpoints))
        \(kind.rawValue) \(typeInformation.typeName.name) {
        \(endpoints.map { endpointMethod(endpoint: $0) }.joined(separator: .doubleLineBreak))
        }
        """
    }
}

extension Array where Element == Parameter {
    func methodSignature() -> String {
        map { "\($0.parameterName.value): \($0.typeInformation.propertyTypeString)" }.joined(separator: ", ")
    }
}

extension Endpoint {
    var queryParameters: [Parameter] {
        parameters.filter { $0.parameterType == .lightweight }
    }
    
    var signatureParameters: [Parameter] {
        parameters
            .filter { $0.parameterType != .header }
            .sorted { $0.parameterName.value < $1.parameterName.value }
    }
    
    var contentParameterString: String {
        if let contentParameter = parameters.first(where: { $0.parameterType == .content }) {
            return "NetworkingService.encode(\(contentParameter.parameterName.value)"
        }
        return "nil"
    }
}

extension Operation {
    var asHTTPMethodString: String {
        switch self {
        case .create: return "post"
        case .read: return "get"
        case .update: return "put"
        case .delete: return "delete"
        }
    }
}
