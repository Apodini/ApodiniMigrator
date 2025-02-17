//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ObjectPropertiesComparator: Comparator {
    let lhs: [TypeProperty]
    let rhs: [TypeProperty]

    func compare(_ context: ChangeComparisonContext, _ results: inout [PropertyChange]) {
        let matchedIds = lhs.matchedIds(with: rhs)
        let removalCandidates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }

        var relaxedMatchings: Set<DeltaIdentifier> = []

        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates.filter { !relaxedMatchings.contains($0.deltaIdentifier) }) {
                relaxedMatchings += relaxedMatching.element.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier

                results.append(.idChange(
                    from: candidate.deltaIdentifier,
                    to: relaxedMatching.element.deltaIdentifier,
                    similarity: relaxedMatching.similarity,
                    breaking: true
                ))

                compare(context, &results, lhs: candidate, rhs: relaxedMatching.element)
            }
        }

        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            let wasRequired = removal.necessity == .required

            var valueId: Int?
            if wasRequired {
                let jsonValue = JSONValue(JSONStringBuilder.jsonString(removal.type, with: context.configuration.encoderConfiguration))
                valueId = context.store(jsonValue: jsonValue)
            }

            results.append(.removal(
                id: removal.deltaIdentifier,
                fallbackValue: valueId,
                breaking: wasRequired,
                solvable: true
            ))
        }

        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            let isRequired = addition.necessity == .required

            var valueId: Int?
            if isRequired {
                let jsonValue = JSONValue(JSONStringBuilder.jsonString(addition.type, with: context.configuration.encoderConfiguration))
                valueId = context.store(jsonValue: jsonValue)
            }

            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition.referencedType(),
                defaultValue: valueId,
                breaking: isRequired,
                solvable: true
            ))
        }

        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched }) {
                compare(context, &results, lhs: lhs, rhs: rhs)
            }
        }
    }

    private func compare(_ context: ChangeComparisonContext, _ results: inout [PropertyChange], lhs: TypeProperty, rhs: TypeProperty) {
        let lhsType = lhs.type
        let rhsType = rhs.type

        var identifierChanges: [ElementIdentifierChange] = []
        let identifiersComparator = ElementIdentifiersComparator(
            lhs: .init(lhs.context.get(valueFor: TypeInformationIdentifierContextKey.self)),
            rhs: .init(rhs.context.get(valueFor: TypeInformationIdentifierContextKey.self))
        )
        identifiersComparator.compare(context, &identifierChanges)

        results.append(contentsOf: identifierChanges.map { change in
            .update(
                id: lhs.deltaIdentifier,
                updated: .identifier(identifier: change),
                breaking: change.breaking,
                solvable: change.solvable
            )
        })

        if lhsType.typeName == rhsType.typeName && lhs.necessity != rhs.necessity {
            let currentLhsType = context.currentVersion(of: lhsType)
            let jsonValue = JSONValue(JSONStringBuilder.jsonString(currentLhsType.unwrapped, with: context.configuration.encoderConfiguration))
            let migrationId = context.store(jsonValue: jsonValue)

            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .necessity(
                    from: lhs.necessity,
                    to: rhs.necessity,
                    necessityMigration: migrationId
                )
            ))
        }

        if lhsType.typeName != rhsType.typeName {
            let jsScriptBuilder = JSScriptBuilder(from: lhsType, to: rhsType, context: context)

            let forwardScript = context.store(script: jsScriptBuilder.convertFromTo)
            let backwardScript = context.store(script: jsScriptBuilder.convertToFrom)

            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .type(
                    from: lhsType.asReference(),
                    to: rhsType.asReference(),
                    forwardMigration: forwardScript,
                    backwardMigration: backwardScript,
                    conversionWarning: jsScriptBuilder.hint
                )
            ))
        }
    }
}
