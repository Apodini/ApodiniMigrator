//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents a migrated endpoint of the client library
class MigratedEndpoint {
    /// Old endpoint of the client library
    let endpoint: Endpoint
    /// Path of `endpoint` in the new version
    private let path: EndpointPath
    /// A flag that indicates whether the endpoint has been deleted in the new version
    let unavailable: Bool
    /// Migrated parameters of the client library (all added, deleted, renamed or updated parameters)
    let parameters: [MigratedParameter]
    
    /// Only `parameters` that have not been deleted, that should be considered in the method body
    var activeParameters: [MigratedParameter] {
        parameters.filter { !$0.deleted }
    }
    
    /// Response string of the endpoint in the old version
    private var responseString: String {
        endpoint.response.unsafeTypeString
    }
    
    /// Initializes a new instance out of an endpoint of the old version, unavailable flag, migrated parameters and the path of the endpoint in the new version
    init(endpoint: Endpoint, unavailable: Bool, parameters: [MigratedParameter], path: EndpointPath) {
        self.endpoint = endpoint
        self.unavailable = unavailable
        self.parameters = parameters.sorted(by: \.oldName)
        self.path = path
    }
    
    /// Returns the input string of the endpoint method considering added parameters and providing default values for those
    private func methodInput() -> String {
        var input = parameters.map { parameter -> String in
            let typeString = parameter.oldType.unsafeTypeString + (parameter.necessity == .optional ? "?" : "")
            var parameterSignature = "\(parameter.oldName): \(typeString)"
            if let defaultValue = parameter.defaultValue {
                parameterSignature += " = try! \(typeString).instance(from: \(defaultValue))"
            }
            
            return parameterSignature
        }
        
        input.append(contentsOf: DefaultEndpointInput.allCases.map { $0.signature })

        return input
            .joined(separator: ",\(String.lineBreak)")
    }
    
    /// Returns the `@available(*, deprecated, message:)` annotation in case that the endpoint has been deleted in the new version
    private func unavailableComment() -> String {
        guard unavailable else {
            return ""
        }
        return "@available(*, deprecated, message: \("This endpoint is not available in the new version anymore. Calling this method results in a failing promise!".doubleQuoted))" + .lineBreak
    }
    
    /// Returns the set value for `parameter` that should be used inside of the method body, considering necessity and convert changes
    private func setValue(for parameter: MigratedParameter) -> String {
        let setValue: String
        if let necessityValueID = parameter.necessityValueJSONId {
            setValue = "\(parameter.oldName) ?? (try! \(parameter.oldType.unsafeTypeString).instance(from: \(necessityValueID)))"
        } else if let convertID = parameter.convertFromTo {
            setValue = "try! \(parameter.newType.unsafeTypeString).from(\(parameter.oldName), script: \(convertID))"
        } else {
            setValue = "\(parameter.oldName)"
        }
        return setValue
    }

    /// Returns the signature of the endpoint method
    @SourceCodeBuilder
    var signature: String {
        let methodName = endpoint.deltaIdentifier.swiftSanitizedName.lowerFirst

        EndpointComment(
            endpoint.handlerName.buildName(componentSeparator: ".", genericsStart: "<", genericsSeparator: ",", genericsDelimiter: ">"),
            path: resourcePath(replaceBrackets: false)
        )

        "\(unavailableComment())static func \(methodName)("
        Indent {
            methodInput()
        }
        ") -> ApodiniPublisher<\(responseString)> {"
    }
    
    /// Returns the adjusted resource path by considering potential renamings of the parameters in the new version and replacing them accordingly
    func resourcePath(replaceBrackets: Bool = true) -> String {
        var resourcePath = path.resourcePath
        
        for pathParameter in activeParameters.filter({ $0.kind == .path }) {
            resourcePath = resourcePath
                .replacingOccurrences(of: "{\(pathParameter.newName)}", with: "{\(pathParameter.oldName)}")
        }
        return replaceBrackets
            ? resourcePath
                .replacingOccurrences(of: "{", with: "\\(")
                .replacingOccurrences(of: "}", with: ")")
            : resourcePath
    }
    
    /// Returns the query parameters string that should be rendered inside of the method body, considering only non-deleted query parameters
    func queryParametersString() -> String {
        let queryParameters = activeParameters.filter { $0.kind == .lightweight }
        guard !queryParameters.isEmpty else {
            return ""
        }
        
        var body = "var parameters = Parameters()" + .lineBreak
        
        for parameter in queryParameters {
            body += "parameters.set(\(setValue(for: parameter)), forKey: \(parameter.newName.doubleQuoted))" + .lineBreak
        }
        
        return body
    }
    
    /// Returns the string that should be used in the `content` field of the handler initializer inside of the endpoint method, by only considering active content parameter
    func contentParameterString() -> String {
        guard let contentParameter = activeParameters.first(where: { $0.kind == .content }) else {
            return "nil"
        }
        
        return "NetworkingService.encode(\(setValue(for: contentParameter)))"
    }
}

// MARK: - Equatable
extension MigratedEndpoint: Equatable {
    static func == (lhs: MigratedEndpoint, rhs: MigratedEndpoint) -> Bool {
        lhs.endpoint == rhs.endpoint
            && lhs.unavailable == rhs.unavailable
            && lhs.parameters == rhs.parameters
            && lhs.path == rhs.path
    }
}

// MARK: - Comparable
extension MigratedEndpoint: Comparable {
    static func < (lhs: MigratedEndpoint, rhs: MigratedEndpoint) -> Bool {
        let lhsEndpoint = lhs.endpoint
        let rhsEndpoint = rhs.endpoint
        if lhsEndpoint.response.unsafeTypeString == rhsEndpoint.response.unsafeTypeString {
            return lhsEndpoint.deltaIdentifier < rhsEndpoint.deltaIdentifier
        }
        return lhsEndpoint.response.unsafeTypeString < rhsEndpoint.response.unsafeTypeString
    }
}
