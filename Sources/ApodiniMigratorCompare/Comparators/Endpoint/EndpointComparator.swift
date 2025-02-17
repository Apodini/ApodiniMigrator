//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct EndpointComparator: Comparator {
    let lhs: Endpoint
    let rhs: Endpoint

    func compare(_ context: ChangeComparisonContext, _ results: inout [EndpointChange]) {
        var identifierChanges: [ElementIdentifierChange] = []
        let identifiersComparator = ElementIdentifiersComparator(lhs: .init(lhs.identifiers), rhs: .init(rhs.identifiers))
        identifiersComparator.compare(context, &identifierChanges)

        results.append(contentsOf: identifierChanges.map { change in
            .update(
                id: lhs.deltaIdentifier,
                updated: .identifier(identifier: change),
                breaking: change.breaking,
                solvable: change.solvable
            )
        })

        if lhs.communicationPattern != rhs.communicationPattern {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .communicationPattern(
                    from: lhs.communicationPattern,
                    to: rhs.communicationPattern
                )
            ))
        }


        var parameterChanges: [ParameterChange] = []
        let parametersComparator = ParametersComparator(lhs: lhs.parameters, rhs: rhs.parameters)
        parametersComparator.compare(context, &parameterChanges)
        results.append(contentsOf: parameterChanges.map { change in
            .update(
                id: lhs.deltaIdentifier,
                updated: .parameter(parameter: change),
                breaking: change.breaking,
                solvable: change.solvable
            )
        })


        // by using `buildString` we exclude the target name from the comparison. We don't care about
        // migrations happening on target level (e.g. moving models between targets).
        if lhs.response.typeName.buildName() != rhs.response.typeName.buildName() {
            let jsScriptBuilder = JSScriptBuilder(from: lhs.response, to: rhs.response, context: context)
            let migrationId = context.store(script: jsScriptBuilder.convertToFrom)

            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .response(
                    from: lhs.response.asReference(),
                    to: rhs.response.asReference(),
                    backwardsMigration: migrationId,
                    migrationWarning: jsScriptBuilder.hint
                )
            ))
        }
    }
}
