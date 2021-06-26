//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

struct WebServiceEndpoint {
    let endpoint: Endpoint
    let unavailable: Bool
    let parameters: [ChangedParameter]
    
    var queryParameters: [ChangedParameter] {
        parameters.filter { $0.kind == .lightweight }
    }
    
    var responseString: String {
        endpoint.response.typeString
    }
    
    init(endpoint: Endpoint, unavailable: Bool, parameters: [ChangedParameter]) {
        self.endpoint = endpoint
        self.unavailable = unavailable
        self.parameters = parameters.sorted(by: \.oldName)
    }
    
    func methodInput() -> String {
        var input = parameters.map { parameter -> String in
            let typeString = parameter.oldType.typeString + (parameter.necessity == .optional ? "?" : "")
            var parameterSignature = "\(parameter.oldName): \(typeString)"
            if let addedValue = parameter.addedValueJSONId {
                parameterSignature += " = \(parameter.necessity == .optional ? "nil" : "try! \(typeString).instance(from: \(addedValue))")"
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
    
    func signature() -> String {
        let methodName = endpoint.deltaIdentifier.rawValue.lowerFirst
        let signature =
        """
        \(unavailableComment())static func \(methodName)(\(methodInput())) -> ApodiniPublisher<\(responseString)> {
        """
        return signature
    }
    
    func unavailableBody() -> String {
        var body = signature()
        body += .lineBreak + "fatalError(\("This endpoint is not available in the new version anymore".doubleQuoted))" + .lineBreak + "}"
        return body
    }
    
    private func setValue(for parameter: ChangedParameter) -> String {
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
    
    func path(pathChange: UpdateChange?) -> String {
        let endpointPath: EndpointPath
        if let pathChange = pathChange, case let .element(anyCodable) = pathChange.to {
            endpointPath = anyCodable.typed(EndpointPath.self)
        } else {
            endpointPath = endpoint.path
        }
        var resourcePath = endpointPath.resourcePath
        
        for pathParameter in parameters.filter({ $0.kind == .path }) {
            resourcePath = resourcePath.with("{\(pathParameter.oldName)}", insteadOf: "{\(pathParameter.newName)}")
        }
        return resourcePath.with("\\(", insteadOf: "{").with(")", insteadOf: "}")
    }
    
}
