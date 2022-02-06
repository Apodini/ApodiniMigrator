//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

struct GRPCMethodResponseWrapping: ResponseTypeWrapping {
    func shouldBeWrapped(endpoint: Endpoint) -> Bool {
        // TODO are enums wrapped as well?
        // TODO are dates/UUIds, data, uuid wrapped?
        endpoint.response.isOptional || endpoint.response.isRepeated || endpoint.response.isScalar
    }

    func wrap(responseType: TypeInformation, of endpoint: Endpoint) -> TypeInformation? {
        // TODO it is crucial that we get the naming right,
        //  property updates will be applied to ProtoMessages
        let typeName = TypeName(
            definedIn: endpoint.handlerName.definedIn,
            rootType: TypeNameComponent(name: endpoint.handlerName.mangledName.appending("Response"))
        )

        return .object(
            name: typeName,
            properties: [
                TypeProperty(
                    name: "value",
                    type: endpoint.response,
                    annotation: nil,
                    context: Context() // context key for grpc identifiers are added later
                )
            ],
            context: Context() // context key for grpc identifiers are added later
        )
    }
}
