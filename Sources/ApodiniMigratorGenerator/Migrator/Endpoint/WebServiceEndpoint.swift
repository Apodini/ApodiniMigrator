//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

struct WebServiceEndpoint: Comparable {
    static func < (lhs: WebServiceEndpoint, rhs: WebServiceEndpoint) -> Bool {
        let lhsEndpoint = lhs.endpoint
        let rhsEndpoint = rhs.endpoint
        if lhsEndpoint.response == rhsEndpoint.response {
            return lhsEndpoint.deltaIdentifier < rhsEndpoint.deltaIdentifier
        }
        return lhsEndpoint.response.typeName.name < rhsEndpoint.response.typeName.name
    }
    
    let endpoint: Endpoint
    let path: EndpointPath
    let unavailable: Bool
    let parameters: [MigratedParameter]
    
    var queryParameters: [MigratedParameter] {
        parameters.filter { $0.kind == .lightweight }
    }
    
    var responseString: String {
        endpoint.response.typeString
    }
    
    init(endpoint: Endpoint, unavailable: Bool, parameters: [MigratedParameter], path: EndpointPath) {
        self.endpoint = endpoint
        self.unavailable = unavailable
        self.parameters = parameters.sorted(by: \.oldName)
        self.path = path
    }
    
    func methodInput() -> String {
        var input = parameters.map { parameter -> String in
            let typeString = parameter.oldType.typeString + (parameter.necessity == .optional ? "?" : "")
            var parameterSignature = "\(parameter.oldName): \(typeString)"
            if let defaultValue = parameter.defaultValue {
                let defaultValueString: String
                if case let .json(id) = defaultValue {
                    defaultValueString = "try! \(typeString).instance(from: \(id))"
                } else {
                    assert(defaultValue.isNone && parameter.necessity == .optional, "Migration guide did not provide a default value for the required added parameter: \(parameter.newName)")
                    defaultValueString = "nil"
                }
                parameterSignature += " = \(defaultValueString)"
            }
            
            return parameterSignature
        }
        
        input.append("authorization: String? = nil")
        input.append("httpHeaders: HTTPHeaders = [:]")
        
        return .lineBreak + input.joined(separator: ",\(String.lineBreak)") + .lineBreak
    }
    
    private func unavailableComment() -> String {
        guard unavailable else {
            return ""
        }
        return "@available(*, unavailable, message: \("This endpoint is not available in the new version anymore. Calling this method results in a fatal error!".doubleQuoted))" + .lineBreak
    }
    
    func signature(asPublic: Bool = false) -> String {
        let methodName = endpoint.deltaIdentifier.rawValue.lowerFirst
        let accessModifier = asPublic ? "public " : ""
        let signature =
        """
        \(EndpointComment(endpoint.handlerName, path: path))
        \(unavailableComment())\(accessModifier)static func \(methodName)(\(methodInput())) -> ApodiniPublisher<\(responseString)> {
        """
        return signature
    }
    
    func unavailableBody(asPublic: Bool = false) -> String {
        var body = signature(asPublic: asPublic)
        body += .lineBreak + "fatalError(\("This endpoint is not available in the new version anymore".doubleQuoted))" + .lineBreak + "}"
        return body
    }
    
    private func setValue(for parameter: MigratedParameter) -> String {
        let setValue: String
        if let necessityValueID = parameter.necessityValueJSONId {
            setValue = "\(parameter.oldName) ?? (try! \(parameter.oldType.typeString).instance(from: \(necessityValueID))"
        } else if let convertID = parameter.convertFromTo {
            setValue = "try! \(parameter.newType.typeString).from(\(parameter.oldName), script: \(convertID))"
        } else {
            setValue = "\(parameter.oldName)"
        }
        return setValue
    }

    func queryParametersString() -> String {
        let queryParameters = self.queryParameters
        guard !queryParameters.isEmpty else {
            return ""
        }
        
        var body = "var parameters = Parameters()" + .lineBreak
        
        for parameter in queryParameters {
            body += "parameters.set(\(setValue(for: parameter)), forKey: \(parameter.newName.doubleQuoted))" + .lineBreak
        }
        
        return body + .lineBreak
    }
    
    func contentParameterString() -> String {
        guard let contentParameter = parameters.firstMatch(on: \.kind, with: .content) else {
            return "nil"
        }
        
        return "NetworkingService.encode(\(setValue(for: contentParameter)))"
    }
    
    func resourcePath() -> String {
        var resourcePath = path.resourcePath
        
        for pathParameter in parameters.filter({ $0.kind == .path }) { // TODO consider convert?
            resourcePath = resourcePath.with("{\(pathParameter.oldName)}", insteadOf: "{\(pathParameter.newName)}")
        }
        return resourcePath.with("\\(", insteadOf: "{").with(")", insteadOf: "}")
    }
    
    
}

public struct WebServiceFileTemplate2: Renderable {
    public static let fileName = "WebService"
    public static let filePath = fileName + .swift
    let endpoints: [WebServiceEndpoint]

    init(_ endpoints: [WebServiceEndpoint]) {
        self.endpoints = endpoints.sorted()
    }


    private func method(for webServiceEndpoint: WebServiceEndpoint) -> String {
        if webServiceEndpoint.unavailable {
            return webServiceEndpoint.unavailableBody(asPublic: true)
        }
        let endpoint = webServiceEndpoint.endpoint
        let nestedType = endpoint.response.nestedType.typeName.name
        var bodyInput = webServiceEndpoint.parameters.map { "\($0.oldName): \($0.oldName)"}
        bodyInput.append("authorization: authorization")
        bodyInput.append("httpHeaders: httpHeaders")
        let body =
        """
        \(webServiceEndpoint.signature(asPublic: true))
        \(nestedType).\(endpoint.deltaIdentifier)(\(String.lineBreak)\(bodyInput.joined(separator: ",\(String.lineBreak)"))\(String.lineBreak))
        }
        """
        return body
    }

    public func render() -> String {
        """
        \(FileHeaderComment(fileName: Self.filePath).render())

        \(Import(.foundation).render())

        \(MARKComment(.endpoints))
        \(Kind.enum.signature) \(Self.fileName) {
        \(endpoints.map { method(for: $0) }.joined(separator: .doubleLineBreak))
        }
        """
    }
}
