//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

struct GRPCMethodParameterCombination: ParameterCombination {
    func shouldBeMapped(parameter: Parameter) -> Bool {
        true // in grpc all parameters are combined!
    }

    func merge(document: APIDocument, endpoint: Endpoint, parameters: [Parameter]) -> Parameter? {
        if parameters.count == 1,
           var first = parameters.first {
            first.dereference(in: document.typeStore)

            if first.typeInformation.protoType == .message || first.typeInformation.protoType == .group {
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

        return Parameter(
            name: "request", // never used anywhere
            typeInformation: typeInformation,
            parameterType: .content, // not used in grpc
            isRequired: true // request is always required in grpc!
        )
    }
}
