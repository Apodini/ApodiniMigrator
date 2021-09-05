//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A typealias of an array of `Parameter`
public typealias EndpointInput = [Parameter]

/// Represents an endpoint
public struct Endpoint: Value, DeltaIdentifiable {
    /// Name of the handler
    public let handlerName: String

    /// Identifier of the handler
    public let deltaIdentifier: DeltaIdentifier

    /// The operation of the endpoint
    public let operation: Operation

    /// The path string of the endpoint
    public let path: EndpointPath

    /// Parameters of the endpoint
    public var parameters: EndpointInput

    /// The reference of the `typeInformation` of the response
    public var response: TypeInformation
    
    /// Errors
    public let errors: [ErrorCode]
    
    /// Initializes a new endpoint instance
    public init(
        handlerName: String,
        deltaIdentifier: String,
        operation: Operation,
        absolutePath: String,
        parameters: EndpointInput,
        response: TypeInformation,
        errors: [ErrorCode]
    ) {
        self.handlerName = handlerName.without(strings: ">", "<", ",")
        var identifier = deltaIdentifier
        if !identifier.split(string: ".").compactMap({ Int($0) }).isEmpty {
            identifier = handlerName.lowerFirst
        }
        self.deltaIdentifier = .init(identifier)
        self.operation = operation
        self.path = .init(absolutePath)
        self.parameters = Self.wrappContentParameters(from: parameters, with: handlerName)
        self.response = response
        self.errors = errors
    }
    
    mutating func dereference(in typeStore: inout TypesStore) {
        response = typeStore.construct(from: response)
        self.parameters = parameters.map {
            var param = $0
            param.dereference(in: &typeStore)
            return param
        }
    }
    
    mutating func reference(in typeStore: inout TypesStore) {
        response = typeStore.store(response)
        self.parameters = parameters.map {
            var param = $0
            param.reference(in: &typeStore)
            return param
        }
    }
    
    /// Returns a version of self where occurrencies of type informations (response or parameters) are references
    public func referencedTypes() -> Endpoint {
        var retValue = self
        var typesStore = TypesStore()
        retValue.reference(in: &typesStore)
        return retValue
    }
}

private extension Endpoint {
    static func wrappContentParameters(from parameters: EndpointInput, with handlerName: String) -> EndpointInput {
        let contentParameters = parameters.filter { $0.parameterType == .content }
        guard !contentParameters.isEmpty else {
            return parameters
        }
        
        var contentParameter: Parameter?
        
        switch contentParameters.count {
        case 1:
            contentParameter = contentParameters.first
        default:
            let typeInformation = TypeInformation.object(
                name: Parameter.wrappedContentParameterTypeName(from: handlerName),
                properties: contentParameters.map {
                    TypeProperty(
                        name: $0.name,
                        type: $0.necessity == .optional ? $0.typeInformation.asOptional : $0.typeInformation
                    )
                }
            )
            
            contentParameter = .init(
                name: Parameter.wrappedContentParameter,
                typeInformation: typeInformation,
                parameterType: .content,
                isRequired: contentParameters.contains(where: { $0.necessity == .required })
            )
        }
        
        var result = parameters.filter { $0.parameterType != .content }
        
        contentParameter.map {
            result.append($0)
        }
        
        return result
    }
}
