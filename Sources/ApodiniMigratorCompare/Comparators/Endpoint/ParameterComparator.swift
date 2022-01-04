//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ParameterComparator: Comparator {
    let lhs: Parameter
    let rhs: Parameter

    func compare(_ context: ChangeComparisonContext, _ results: inout [ParameterChange]) {
        if lhs.parameterType != rhs.parameterType {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .parameterType(
                    from: lhs.parameterType,
                    to: rhs.parameterType
                )
            ))
        }

        if lhs.necessity != rhs.necessity {
            let jsonValue = JSONValue(JSONStringBuilder.jsonString(rhs.typeInformation, with: context.configuration.encoderConfiguration))
            let jsonId = context.store(jsonValue: jsonValue)

            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .necessity(
                    from: lhs.necessity,
                    to: rhs.necessity,
                    necessityMigration: jsonId
                ),
                breaking: rhs.necessity == .required
            ))
        }

        // by using `buildString` we exclude the target name from the comparison. We don't care about
        // migrations happening on target level (e.g. moving models between targets).
        if lhs.typeInformation.typeName.buildName() != rhs.typeInformation.typeName.buildName() {
            let jsScriptBuilder = JSScriptBuilder(from: lhs.typeInformation, to: rhs.typeInformation, context: context)
            let migrationId = context.store(script: jsScriptBuilder.convertFromTo)

            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .type(
                    from: lhs.typeInformation.asReference(),
                    to: rhs.typeInformation.asReference(),
                    forwardMigration: migrationId,
                    conversionWarning: jsScriptBuilder.hint
                )
            ))
        }
    }
}
