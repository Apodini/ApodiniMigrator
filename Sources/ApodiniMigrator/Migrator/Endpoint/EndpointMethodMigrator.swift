//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

class EndpointMethodMigrator: Renderable {
    /// Endpoint of old version that will be migrated
    private let endpoint: Endpoint
    /// A flag that indicates whether the endpoint has been deleted in the new version
    private let unavailable: Bool
    /// Only changes that belong to `endpoint`
    private let endpointChanges: [Change]
    /// Migrated parameters of the endpoint by means of `endpointChanges`, property gets initialized by from `Self.migratedParameters(of:with:)` static method
    private let parameters: [MigratedParameter]
    /// Lazy migrated endpoint property.
    lazy var migratedEndpoint: MigratedEndpoint = {
        .init(endpoint: endpoint, unavailable: unavailable, parameters: parameters, path: path())
    }()
    
    /// An optional property that holds the id of the javascript convert function in case that response changed to some other type. Property set in `responseString()`
    private var responseConvertID: Int?
    
    /// Initializes a new instance out of an endpoint of old version and the changes that belong to `endpoint`
    init(_ endpoint: Endpoint, changes: [Change]) {
        self.endpoint = endpoint
        self.endpointChanges = changes
        
        unavailable = endpointChanges.contains(where: { $0.type == .deletion && $0.element.target == EndpointTarget.`self`.rawValue })
        parameters = Self.migratedParameters(of: endpoint, with: endpointChanges)
    }
    
    /// Returns the string raw value of `target`
    private func target(_ target: EndpointTarget) -> String {
        target.rawValue
    }
    
    /// Checks changes whether the response has changed to some other types. If that is the case returns the string of the new response type
    /// and saves the corresponding convert id in `responseConvertID`, otherwise returns the string of the old response type
    private func responseString() -> String {
        if let responseChange = endpointChanges.firstMatch(on: \.type, with: .responseChange) as? UpdateChange, case let .element(anyCodable) = responseChange.to {
            guard let convertID = responseChange.convertToFrom else {
                fatalError("Response change did not provide an id for converting the response")
            }
            responseConvertID = convertID
            let response = anyCodable.typed(TypeInformation.self)
            return response.typeString
        }
        return endpoint.response.typeString
    }
    
    /// Checks changes whether the operation has changed, if that is the case, returns the `operation` of the new version, otherwise the `operation` of `endpoint`
    private func operation() -> ApodiniMigratorCore.Operation {
        if
            let operationChange = endpointChanges.first(where: { $0.element.target == target(.operation) }) as? UpdateChange,
            case let .element(anyCodable) = operationChange.to {
            return anyCodable.typed(ApodiniMigratorCore.Operation.self)
        }
        return endpoint.operation
    }
    
    /// Checks whether the `path` has changed, if that is the case the new path is returned, otherwise the `path` of `endpoint`
    private func path() -> EndpointPath {
        if
            let pathChange = endpointChanges.first(where: { $0.element.target == target(.resourcePath) }) as? UpdateChange,
            case let .element(anyCodable) = pathChange.to {
            return anyCodable.typed(EndpointPath.self)
        }
        return endpoint.path
    }
    
    /// If response has changed, the migrator converts the return of the function to the old type by means of the `responseConvertID` saved from `responseString()`.
    private func returnValueString() -> String {
        var retValue = "return NetworkingService.trigger(handler)"
        guard let convertID = responseConvertID else {
            return retValue
        }
        let indentationPlaceholder = Indentation.placeholder
        retValue += .lineBreak + indentationPlaceholder + ".tryMap { try \(endpoint.response.typeString).from($0, script: \(convertID)) }" + .lineBreak
        retValue += indentationPlaceholder + ".eraseToAnyPublisher()"
        return retValue
    }
    
    /// Renders the body of the migrated endpoint
    func render() -> String {
        if unavailable {
            return migratedEndpoint.unavailableBody()
        }
        
        let responseString = self.responseString()
        let queryParametersString = migratedEndpoint.queryParametersString()
        let body =
        """
        \(migratedEndpoint.signature())
        \(queryParametersString)var headers = httpHeaders
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        \(endpoint.errors.map { "errors.addError(\($0.code), message: \($0.message.doubleQuoted))" }.lineBreaked)

        let handler = Handler<\(responseString)>(
        path: \(migratedEndpoint.resourcePath().doubleQuoted),
        httpMethod: .\(operation().asHTTPMethodString),
        parameters: \(queryParametersString.isEmpty ? "[:]" : "parameters"),
        headers: headers,
        content: \(migratedEndpoint.contentParameterString()),
        authorization: authorization,
        errors: errors
        )

        \(returnValueString())
        }
        """
        return body
    }
}

// MARK: - EndpointMethodMigrator
fileprivate extension EndpointMethodMigrator {
    /// Returns the migrated endpoints of `endpoint` by means of `endpointChanges`, by taking into account all changes that target paramaters
    // swiftlint:disable:next function_body_length
    static func migratedParameters(of endpoint: Endpoint, with endpointChanges: [Change]) -> [MigratedParameter] {
        var parameters: [MigratedParameter] = []
        let parameterTargets = [EndpointTarget.queryParameter, .pathParameter, .contentParameter].map { $0.rawValue }
        
        // First registering additions and deletions
        for change in endpointChanges where parameterTargets.contains(change.element.target) && [.addition, .deletion].contains(change.type) {
            if
                let addChange = change as? AddChange,
                case let .element(anyCodable) = addChange.added
            {
                parameters.append(.addedParameter(anyCodable.typed(Parameter.self), defaultValue: addChange.defaultValue))
            } else if
                let deleteChange = change as? DeleteChange,
                case let .elementID(id) = deleteChange.deleted,
                let oldParameter = endpoint.parameters.firstMatch(on: \.deltaIdentifier, with: id)
            {
                parameters.append(.deletedParameter(oldParameter))
            }
        }
        
        // Iterating through old parameters that have not been deleted and registering the corresponding changes
        for oldParameter in endpoint.parameters where !parameters.contains(where: { $0.oldName == oldParameter.name }) {
            let oldName = oldParameter.name
            let oldType = oldParameter.typeInformation
            var newType: TypeInformation?
            var parameterType: ParameterType?
            var newName: String?
            var necessityValueJSONId: Int?
            var convertFromToJSONId: Int?
            // All changes related to parameters are of type `UpdateChange`
            for change in endpointChanges where (change as? UpdateChange)?.targetID == oldParameter.deltaIdentifier {
                if let updateChange = change as? UpdateChange {
                    if updateChange.type == .rename, case let .stringValue(rename) = updateChange.to {
                        newName = rename
                        continue
                    }
                    
                    if updateChange.parameterTarget == .kind, case let .element(anyCodable) = updateChange.to {
                        parameterType = anyCodable.typed(ParameterType.self)
                        continue
                    }
                    
                    if let necessityValue = updateChange.necessityValue, case let .json(id) = necessityValue {
                        necessityValueJSONId = id
                        assert(convertFromToJSONId == nil, "Provided necessity value for a parameter that already has a convert method")
                        continue
                    }
                    
                    if
                        updateChange.parameterTarget == .typeInformation,
                        let convertFromTo = updateChange.convertFromTo,
                        case let .element(anyCodable) = updateChange.to
                    {
                        convertFromToJSONId = convertFromTo
                        newType = anyCodable.typed(TypeInformation.self)
                        assert(necessityValueJSONId == nil, "Provided a convert method for a parameter that already has a necessity value")
                    }
                }
            }
            
            parameters.append(
                .init(
                    oldName: oldName,
                    newName: newName ?? oldName,
                    kind: parameterType ?? oldParameter.parameterType,
                    necessity: oldParameter.necessity,
                    oldType: oldType,
                    newType: newType ?? oldType,
                    convertFromTo: convertFromToJSONId,
                    defaultValue: nil,
                    necessityValueJSONId: necessityValueJSONId,
                    deleted: false
                )
            )
        }
        return parameters
    }
}

// MARK: - Operation
fileprivate extension ApodiniMigratorCore.Operation {
    var asHTTPMethodString: String {
        switch self {
        case .create: return "post"
        case .read: return "get"
        case .update: return "put"
        case .delete: return "delete"
        }
    }
}
