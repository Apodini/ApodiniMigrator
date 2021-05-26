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
            .sorted(by: \.parameterName)
    }
    
    func methodInputString() -> String {
        signatureParameters
            .map { "\($0.name): \($0.typeInformation.typeString)" }
            .joined(separator: ", ")
    }
    
    var queryParametersString: String {
        let queryParameters = parameters.filter(.lightweight)
        guard !queryParameters.isEmpty else {
            return ""
        }
        let string =
        """
        var parameters = Parameters()
        \(queryParameters.map { "parameters.set(\($0.name), forKey: \($0.name.asString))" }.lineBreaked)
        """
        return string + .doubleLineBreak
    }
    
    var contentParameterString: String {
        if let contentParameter = parameters.first(where: { $0.parameterType == .content }) {
            return "NetworkingService.encode(\(contentParameter.name)"
        }
        return "nil"
    }
}
