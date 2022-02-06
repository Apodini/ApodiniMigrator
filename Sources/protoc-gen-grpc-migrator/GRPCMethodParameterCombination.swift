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

    init(typeStore: TypesStore) {
        self.typeStore = typeStore
    }

    func shouldBeMapped(parameter: Parameter) -> Bool {
        true // in grpc all parameters are combined!
    }

    // TODO we also do reponse type wrapping!

    func merge(endpoint: Endpoint, parameters: [Parameter]) -> Parameter? {
        // TODO insert Empty if there are zero parameters!

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

        // TODO save for which endpoint we combine parameters.
        //  => if the endpoint already existed we would need to check under the updated name
        //  for newly added properties?

        return Parameter(
            name: "request", // never used anywhere
            typeInformation: typeInformation,
            parameterType: .content, // not used in grpc
            isRequired: true // request is always required in grpc!
        )
    }
}
