//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

extension Array where Element == Parameter {
    func filter(_ parameterType: ParameterType) -> Self {
        filter { $0.parameterType == parameterType }
    }
}

extension Endpoint {
    var signatureParameters: [Parameter] {
        parameters
            .filter { $0.parameterType != .header }
            .sorted(by: \.name)
    }
    
    func methodInputString() -> String {
        var signatureParameters = self.signatureParameters.sorted(by: \.name)
        if let authorization = authorization {
            signatureParameters.append(authorization)
        }
        
        return signatureParameters
            .map { "\($0.name): \($0.typeInformation.typeString)\($0.parameterType == .path ? "" : $0.necessity == .optional ? "?" : "")" }
            .joined(separator: ", ")
    }
    
    var authorization: Parameter? {
        if let authorization = parameters.first(where: { $0.parameterType == .header && $0.name == "Authorization" }) {
            return .init(
                name: authorization.name.lowerFirst,
                typeInformation: authorization.typeInformation,
                parameterType: authorization.parameterType,
                isRequired: authorization.necessity == .required
            )
        }
        return nil
    }
    
    var hasAuthorization: Bool {
        authorization != nil
    }
    
    var queryParametersString: String {
        let queryParameters = parameters.filter(.lightweight)
        guard !queryParameters.isEmpty else {
            return ""
        }
        let string =
        """
        var parameters = Parameters()
        \(queryParameters.map { "parameters.set(\($0.name), forKey: \($0.name.doubleQuoted))" }.lineBreaked)
        """
        return string + .doubleLineBreak
    }
    
    var contentParameterString: String {
        if let contentParameter = parameters.firstMatch(on: \.parameterType, with: .content) {
            return "NetworkingService.encode(\(contentParameter.name))"
        }
        return "nil"
    }
}
