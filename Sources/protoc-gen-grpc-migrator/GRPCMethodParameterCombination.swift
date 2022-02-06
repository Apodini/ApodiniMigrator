//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

class GRPCMethodParameterCombination: ParameterCombination {
    let shouldCallForZeroParameters = false

    let typeStore: TypesStore

    init(typeStore: TypesStore) {
        self.typeStore = typeStore
    }

    func shouldBeMapped(parameter: Parameter) -> Bool {
        true // in grpc all parameters are combined!
    }

    func merge(parameters: [Parameter], of endpoint: Endpoint) -> Parameter? {
        if parameters.isEmpty {
            // TODO insert parameter with grpc Empty Type if there are zero parameters!
            //  (requires modifications in the ParameterCombination to be passed here!
            preconditionFailure("We currently do not support combining parameters with zero parameters: \(endpoint)")
        }

        if parameters.count == 1,
           var first = parameters.first {
            first.dereference(in: typeStore)

            if (first.typeInformation.protoType == .message || first.typeInformation.protoType == .group)
                   && !first.typeInformation.isRepeated {
                // we (and ApodiniGRPC) don't care if the web service declared this property as optional.
                // grpc requires parameter to be required and it doesn't hurt to always send a optional parameter.
                return nil
            }
        }

        // TODO it is crucial that we get the naming right,
        //  property updates will be applied to ProtoMessages
        let typeName = TypeName(
            definedIn: endpoint.handlerName.definedIn,
            // TODO maybe use the grpc method name?
            rootType: TypeNameComponent(name: endpoint.handlerName.mangledName.appending("Input"))
        )

        let typeInformation: TypeInformation = .object(
            name: typeName,
            properties: parameters.map { TypeProperty(from: $0) },
            context: Context() // context key for grpc identifiers are added later on
        )

        return Parameter(
            name: "request", // never used anywhere
            typeInformation: typeInformation,
            parameterType: .content, // not used in grpc
            isRequired: true // request is always required in grpc!
        )
    }
}
