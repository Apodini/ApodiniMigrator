//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

class EndpointMethodMigrator: SourceCodeRenderable {
    /// Endpoint of old version that will be migrated
    private let endpoint: Endpoint
    /// A flag that indicates whether the endpoint has been deleted in the new version
    private let unavailable: Bool

    private var path: EndpointPath
    private var operation: ApodiniMigratorCore.Operation

    private var responseString: String
    /// An optional property that holds the id of the javascript convert function in case that response changed to some other type. Property set in `responseString()`
    private var responseConvertID: Int?

    /// Lazy migrated endpoint property.
    let migratedEndpoint: MigratedEndpoint
    
    /// Initializes a new instance out of an endpoint of old version and the changes that belong to `endpoint`
    init(_ endpoint: Endpoint, changes: [EndpointChange]) { // swiftlint:disable:this function_body_length cyclomatic_complexity
        self.endpoint = endpoint
        self.unavailable = changes.contains(where: { $0.type == .removal })

        self.path = endpoint.identifier()
        self.operation = endpoint.identifier()

        self.responseString = endpoint.response.unsafeTypeString

        var parameters: [MigratedParameter] = []

        var removedParameters: Set<DeltaIdentifier> = []
        // index parameter changes by the parameter identifier
        var updatedParameters: [DeltaIdentifier: [ParameterChange.UpdateChange]] = [:]
        var renamedParameters: [DeltaIdentifier: ParameterChange.IdentifierChange] = [:]

        for endpointUpdate in changes.compactMap({ $0.modeledUpdateChange }) {
            switch endpointUpdate.updated {
            case let .identifier(identifierChange):
                guard identifierChange.id.rawValue == Operation.identifierType
                          || identifierChange.id.rawValue == EndpointPath.identifierType else {
                    continue
                }

                guard let updateChange = identifierChange.modeledUpdateChange else {
                    fatalError("Encountered unsupported change type for required endpoint identifier: \(identifierChange)")
                }

                switch updateChange.id.rawValue {
                case Operation.identifierType:
                    self.operation = updateChange.updated.to.typed()
                case EndpointPath.identifierType:
                    self.path = updateChange.updated.to.typed()
                default:
                    break
                }
            case let .response(from, to, migration, warning):
                self.responseString = to.unsafeTypeString
                self.responseConvertID = migration
            case let .parameter(parameter):
                if let parameterAddition = parameter.modeledAdditionChange {
                    parameters.append(.addedParameter(parameterAddition.added, defaultValue: parameterAddition.defaultValue))
                } else if let parameterRemoval = parameter.modeledRemovalChange {
                    guard let parameter = endpoint.parameters.first(where: { $0.deltaIdentifier == parameterRemoval.id }) else {
                        fatalError("Failed to match removal change with parameter in API document!")
                    }
                    parameters.append(.deletedParameter(parameter))
                    removedParameters.insert(parameterRemoval.id)
                } else if let parameterUpdate = parameter.modeledUpdateChange {
                    updatedParameters[parameterUpdate.id, default: []]
                        .append(parameterUpdate)
                } else if let parameterIdentifierChange = parameter.modeledIdentifierChange {
                    renamedParameters[parameterIdentifierChange.from] = parameterIdentifierChange
                }
            default:
                break
            }
        }

        for parameter in endpoint.parameters where !removedParameters.contains(parameter.deltaIdentifier) {
            var newName: String?
            var newType: TypeInformation?
            var parameterType: ParameterType?
            var necessityValueJSONId: Int?
            var convertFromToJSONId: Int?

            if let identifierChange = renamedParameters[parameter.deltaIdentifier] {
                newName = identifierChange.to.rawValue
            }

            for change in updatedParameters[parameter.deltaIdentifier, default: []] {
                switch change.updated {
                case let .parameterType(from, to):
                    parameterType = to
                case let .necessity(from, to, migration):
                    necessityValueJSONId = migration
                    precondition(convertFromToJSONId == nil, "Provided necessity value for a parameter that already has a convert method")
                case let .type(from, to, forwardMigration, warning):
                    convertFromToJSONId = forwardMigration
                    newType = to
                    precondition(necessityValueJSONId == nil, "Provided a convert method for a parameter that already has a necessity value")
                }
            }

            parameters.append(MigratedParameter(
                oldName: parameter.name,
                newName: newName ?? parameter.name,
                kind: parameterType ?? parameter.parameterType,
                necessity: parameter.necessity,
                oldType: parameter.typeInformation,
                newType: newType ?? parameter.typeInformation,
                convertFromTo: convertFromToJSONId,
                defaultValue: nil,
                necessityValueJSONId: necessityValueJSONId,
                deleted: false
            ))
        }

        self.migratedEndpoint = MigratedEndpoint(endpoint: endpoint, unavailable: unavailable, parameters: parameters, path: path)
    }

    @SourceCodeBuilder
    private var returnValueString: String {
        "return NetworkingService.trigger(handler)"

        if let convertID = responseConvertID {
            Indent {
                """
                .tryMap { try \(endpoint.response.unsafeTypeString).from($0, script: \(convertID)) }
                .eraseToAnyPublisher()
                """
            }
        }
    }

    /// Renders the body of the migrated endpoint
    var renderableContent: String {
        migratedEndpoint.signature

        Indent {
            if unavailable {
                "Future { $0(.failure(ApodiniError.deletedEndpoint())) }.eraseToAnyPublisher()"
            } else {
                let queryParametersString = migratedEndpoint.queryParametersString()

                if !queryParametersString.isEmpty {
                    queryParametersString
                }

                """
                var headers = httpHeaders
                headers.setContentType(to: "application/json")

                var errors: [ApodiniError] = []
                """
                for error in endpoint.errors {
                    "errors.addError(\(error.code), message: \"\(error.message)\")"
                }

                """

                let handler = Handler<\(responseString)>(
                """
                Indent {
                    """
                    path: "\(migratedEndpoint.resourcePath())",
                    httpMethod: .\(operation.asHTTPMethodString),
                    parameters: \(queryParametersString.isEmpty ? "[:]" : "parameters"),
                    headers: headers,
                    content: \(migratedEndpoint.contentParameterString()),
                    authorization: authorization,
                    errors: errors
                    """
                }
                ")"

                ""
                returnValueString
            }
        }
        "}"
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
