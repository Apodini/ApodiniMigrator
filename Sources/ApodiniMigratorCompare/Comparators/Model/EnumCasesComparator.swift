//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct EnumCasesComparator: Comparator {
    let lhs: [EnumCase]
    let rhs: [EnumCase]

    func compare(_ context: ChangeComparisonContext, _ results: inout [EnumCaseChange]) {
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

                if candidate.rawValue != relaxedMatching.element.rawValue {
                    results.append(.update(
                        id: candidate.deltaIdentifier,
                        updated: .rawValue(from: candidate.rawValue, to: relaxedMatching.element.rawValue)
                    ))
                }
            }
        }

        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            results.append(.removal(
                id: removal.deltaIdentifier,
                solvable: true
            ))
        }

        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition
            ))
        }

        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched }) {
                compare(context, &results, lhs: lhs, rhs: rhs)
            }
        }
    }

    private func compare(_ context: ChangeComparisonContext, _ results: inout [EnumCaseChange], lhs: EnumCase, rhs: EnumCase) {
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

        if lhs.rawValue != rhs.rawValue {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .rawValue(from: lhs.rawValue, to: rhs.rawValue)
            ))
        }
    }
}
