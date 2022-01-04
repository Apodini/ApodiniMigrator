//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ParametersComparator: Comparator {
    let lhs: [Parameter]
    let rhs: [Parameter]

    func compare(_ context: ChangeComparisonContext, _ results: inout [ParameterChange]) {
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

                let parameterComparator = ParameterComparator(lhs: candidate, rhs: relaxedMatching.element)
                parameterComparator.compare(context, &results)
            }
        }

        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            results.append(.removal(
                id: removal.deltaIdentifier,
                breaking: false,
                solvable: true
            ))
        }

        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            var defaultValueId: Int?
            let isRequired = addition.necessity == .required
            if isRequired {
                let defaultJsonValue = JSONValue(
                    JSONStringBuilder.jsonString(addition.typeInformation, with: context.configuration.encoderConfiguration)
                )
                defaultValueId = context.store(jsonValue: defaultJsonValue)
            }

            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition.referencedType(),
                defaultValue: defaultValueId,
                breaking: isRequired
            ))
        }

        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched }) {
                let parameterComparator = ParameterComparator(lhs: lhs, rhs: rhs)
                parameterComparator.compare(context, &results)
            }
        }
    }
}
