//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A typealias of an array of `Parameter`
public typealias EndpointInput = [Parameter] // TODO remove

public protocol EndpointIdentifier: RawRepresentable where Self.RawValue == String {
    static var type: String { get }
}

public extension EndpointIdentifier {
    static var type: String {
        "\(Self.self)"
    }
}

public struct AnyEndpointIdentifier: Value {
    public let rawValue: String
}

/// Represents an endpoint
public struct Endpoint: Value, DeltaIdentifiable {
    /// Name of the handler
    public let handlerName: String // TODO this is also identifier
    /// Identifier of the handler
    public let deltaIdentifier: DeltaIdentifier // TODO is this party of the identifier?

    public var identifiers: [String: AnyEndpointIdentifier]

    /*
    /// The operation of the endpoint
    public let operation: Operation // TODO "Identifier"

    /// The communicational pattern of the endpoint.
    public let communicationalPattern: CommunicationalPattern

    /// The path string of the endpoint
    public let path: EndpointPath // TODO identifier

    // TODO gRPC identifier! (how to integrate?)
    public var grpcIdentifier: String?
    */

    /// Parameters of the endpoint
    public var parameters: EndpointInput

    /// The reference of the `typeInformation` of the response
    public var response: TypeInformation
    
    /// Errors
    public let errors: [ErrorCode] // TODO support parsing ApodiniErrors in the Exporter!
    
    /// Initializes a new endpoint instance
    public init(
        handlerName: String,
        deltaIdentifier: String,
        operation: Operation,
        communicationalPattern: CommunicationalPattern,
        absolutePath: String,
        parameters: EndpointInput,
        response: TypeInformation,
        errors: [ErrorCode]
    ) {
        self.handlerName = handlerName
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ",", with: "")

        var identifier = deltaIdentifier
        // checks for "x.x.x." style Apodini identifiers! TODO manual match!?
        if !identifier.split(separator: ".").compactMap({ Int($0) }).isEmpty {
            identifier = handlerName.lowerFirst
            // TODO handlerName can only be used as identifier if the component is unique throughout the whole
            //   web service. We MUST fail if a certain Handler is used multiple times in the web service!
            //    => we should fail in the Exporter for this!
            //    => or use the apodini position based identifier?
        }
        self.deltaIdentifier = .init(identifier)
        self.identifiers = [:]

        self.parameters = Self.wrappContentParameters(from: parameters, with: handlerName)
        self.response = response
        self.errors = errors

        self.add(identifier: operation)
        self.add(identifier: communicationalPattern)
        self.add(identifier: EndpointPath(absolutePath))
    }

    public mutating func add<Identifier: EndpointIdentifier>(identifier: Identifier) {
        self.identifiers[Identifier.type] = AnyEndpointIdentifier(rawValue: identifier.rawValue)
    }

    // TODO naming
    public mutating func Oidentifier<Identifier: EndpointIdentifier>(for type: Identifier.Type = Identifier.self) -> Identifier? {
        guard let rawValue = self.identifiers[Identifier.type]?.rawValue else {
            return nil
        }

        return Identifier(rawValue: rawValue)
    }

    public mutating func identifier<Identifier: EndpointIdentifier>(for type: Identifier.Type = Identifier.self) -> Identifier {
        guard let identifier = Oidentifier(for: Identifier.self) else {
            fatalError("aASD") // TODO message
        }

        return identifier
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
    // TODO this is REST specific!
    // TODO we have something similar (Parameter Wrapping) for GRPC
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
