//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

class EndpointMethodMigrator: Renderable {
    
    let endpoint: Endpoint
    let unavailable: Bool // TODO added endpoint, skip other steps
    let endpointChanges: [Change]
    private var parameters: [ChangedParameter] = []
    var webServiceEndpoint: WebServiceEndpoint {
        .init(endpoint: endpoint, unavailable: unavailable, parameters: parameters)
    }
    
    var responseConvertID: Int?
    var newResponse: TypeInformation?
    
    init(_ endpoint: Endpoint, changes: [Change]) {
        self.endpoint = endpoint
        self.endpointChanges = changes.filter { $0.elementID == endpoint.deltaIdentifier }
        
        unavailable = endpointChanges.contains(where: { $0.type == .deletion && $0.element.target == EndpointTarget.`self`.rawValue })
        setupParameters()
    }
//    if typesNeedConvert(lhs: lhsResponse, rhs: rhsResponse) {
//        let jsScriptBuilder = JSScriptBuilder(from: lhsResponse, to: rhsResponse, changes: changes, encoderConfiguration: configuration)
//        changes.add(
//            UpdateChange(
//                element: element(.response),
//                from: .element(reference(lhs.response)),
//                to: .element(reference(rhs.response)),
//                convertToFrom: changes.store(script: jsScriptBuilder.convertToFrom),
//                convertionWarning: jsScriptBuilder.hint,
//                breaking: true,
//                solvable: true
//            )
//        )
//    }
    
    private func responseString() -> String {
        if let responseChange = endpointChanges.firstMatch(on: \.type, with: .responseChange) as? UpdateChange, case let .element(anyCodable) = responseChange.to {
            guard let convertID = responseChange.convertToFrom else {
                fatalError("Response change did not provide an id for converting the response")
            }
            responseConvertID = convertID
            let response = anyCodable.typed(TypeInformation.self)
            newResponse = response
            return response.typeString
        }
        return endpoint.response.typeString
    }
    
    private func operation() -> ApodiniMigrator.Operation {
        if let operationChange = endpointChanges.first(where: { $0.element.target == EndpointTarget.operation.rawValue }) as? UpdateChange, case let .element(anyCodable) = operationChange.to {
            return anyCodable.typed(ApodiniMigrator.Operation.self)
        }
        return endpoint.operation
    }
    
    func render() -> String {
        let webServiceEndpoint = self.webServiceEndpoint
        guard !webServiceEndpoint.unavailable else {
            return webServiceEndpoint.unavailableBody()
        }
        
        let path = endpoint.path.resourcePath.replacingOccurrences(of: "{", with: "\\(").replacingOccurrences(of: "}", with: ")")
        let responseString = self.responseString()
        let queryParametersString = webServiceEndpoint.queryParametersString()
        let methodName = endpoint.deltaIdentifier
        let body =
        """
        \(EndpointComment(endpoint))
        \(webServiceEndpoint.signature())
        \(queryParametersString)var headers = httpHeaders
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        \(endpoint.errors.map { "errors.addError(\($0.code), message: \($0.message.doubleQuoted))" }.lineBreaked)

        let handler = Handler<\(responseString)>(
        path: \(webServiceEndpoint.path(pathChange: endpointChanges.first(where: { $0.element.target == EndpointTarget.resourcePath.rawValue }) as? UpdateChange).doubleQuoted),
        httpMethod: .\(self.operation().asHTTPMethodString),
        parameters: \(queryParametersString.isEmpty ? "[:]" : "parameters"),
        headers: headers,
        content: \(webServiceEndpoint.contentParameterString()),
        authorization: authorization,
        errors: errors
        )

        \(returnValueString())
        }
        """
        return body
    }
    
    private func returnValueString() -> String {
        var base = "return NetworkingService.trigger(handler)"
        guard let convertID = responseConvertID else {
            return base
        }
        let indentationPlaceholder = Indentation.placeholder
        base += .lineBreak + indentationPlaceholder + ".tryMap { try \(endpoint.response.typeString).from($0, script: \(convertID)) }" + .lineBreak
        base += indentationPlaceholder + ".eraseToAnyPublisher()"
        return base
    }
    
    private func setupParameters() {
        let parameterTargets = [EndpointTarget.queryParameter, .pathParameter, .contentParameter].map { $0.rawValue }
        
        for change in endpointChanges where parameterTargets.contains(change.element.target) && [.addition, .deletion].contains(change.type) {
            if let addChange = change as? AddChange, case let .element(anyCodable) = addChange.added {
                var jsonValueID: Int?
                if case let .json(id) = addChange.defaultValue {
                    jsonValueID = id
                }
                let parameter = anyCodable.typed(Parameter.self)
                parameters.append(.addedParameter(parameter, jsonValueID: jsonValueID))
            } else if let deleteChange = change as? DeleteChange, case let .elementID(id) = deleteChange.deleted, let oldParameter = endpoint.parameters.firstMatch(on: \.deltaIdentifier, with: id) {
                parameters.append(.deletedParameter(oldParameter))
            }
        }
        
        for oldParameter in endpoint.parameters where !parameters.contains(where: { $0.oldName == oldParameter.name }) {
            let oldName = oldParameter.name
            let oldType = oldParameter.typeInformation
            var newType: TypeInformation?
            var parameterType: ParameterType?
            var newName: String?
            var necessityValueJSONId: Int?
            var convertFromToJSONId: Int?
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
                    
                    if updateChange.parameterTarget == .typeInformation, let convertFromTo = updateChange.convertFromTo, case let .element(anyCodable) = updateChange.to {
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
                    addedValueJSONId: nil,
                    necessityValueJSONId: necessityValueJSONId,
                    deleted: false
                )
            )
        }
    }
}
