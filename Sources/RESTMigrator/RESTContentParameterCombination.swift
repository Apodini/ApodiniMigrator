//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//


import Foundation
import ApodiniMigrator

struct RESTContentParameterCombination: ParameterCombination {
    func shouldBeMapped(parameter: Parameter) -> Bool {
        parameter.parameterType == .content
    }

    func merge(endpoint: Endpoint, parameters: [Parameter]) -> Parameter? {
        if parameters.count == 1 { // we don't need to merge if its just a single parameter
            return nil
        }

        let typeName = TypeName(
            rawValue: endpoint.handlerName
                .buildName()
                .replacingOccurrences(of: "Handler", with: "")
                .upperFirst
                .appending("WrappedContent")
        )

        let typeInformation: TypeInformation = .object(
            name: typeName,
            properties: parameters.map(TypeProperty.init),
            context: Context() // just create an empty one
        )

        return Parameter(
            name: "wrappedContentParameter",
            typeInformation: typeInformation,
            parameterType: .content,
            isRequired: parameters.contains(where: { $0.necessity == .required })
        )
    }
}
