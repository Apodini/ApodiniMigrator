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
    let typeStore: TypesStore

    // with this variable we track which models got added. We require this information,
    // as we need to update our deltaIdentifier->TypeName mapping (used when processing model changes)
    var newlyCreatedModels: [TypeInformation] = []

    init(typeStore: TypesStore) {
        self.typeStore = typeStore
    }

    func shouldBeMapped(parameter: Parameter) -> Bool {
        true // in grpc all parameters are combined!
    }

    func merge(endpoint: Endpoint, parameters: [Parameter]) -> Parameter? {
        if parameters.count == 1,
           var first = parameters.first {
            first.dereference(in: typeStore)

            if (first.typeInformation.protoType == .message || first.typeInformation.protoType == .group)
                && !first.typeInformation.isOptional {
                // TODO how does ApodiniGRPC react to optional single parameters,
                //   => does it introduce a wrapper type on necessity changes?
                return nil
            }
        }

        let typeName = TypeName(
            // TODO prepend with the packageName!
            rawValue: endpoint.handlerName
                .rawValue // TODO how to handle generics in the name
                .appending("___INPUT")
        )

        let typeInformation: TypeInformation = .object(
            name: typeName,
            properties: parameters.map(TypeProperty.init),
            context: Context() // TODO grpc Context keys if we ever get this way
        )

        newlyCreatedModels.append(typeInformation)

        return Parameter(
            name: "request", // never used anywhere
            typeInformation: typeInformation,
            parameterType: .content, // not used in grpc
            isRequired: true // request is always required in grpc!
        )
    }
}
