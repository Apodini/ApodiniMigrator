//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

struct EnumComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    
    func element(_ target: EnumTarget) -> ChangeElement {
        .for(enum: lhs, target: target)
    }

    func compare(_ context: ChangeComparisonContext, _ results: inout [ModelChange]) {
        guard let lhsRawValue = lhs.rawValueType, let rhsRawValue = rhs.rawValueType else {
            fatalError("Encountered non enum when comparing enum models")
        }

        if lhsRawValue != rhsRawValue {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .rawValueType(
                    from: lhsRawValue.referenced(),
                    to: rhsRawValue.referenced()
                ),
                solvable: false
            ))

            // TODO
            //  UnsupportedChange(
            //      element: element(.`self`),
            //      description: "The raw value type of this enum has changed to \(rhsRawValue.nestedTypeString). ApodiniMigrator is not able to migrate this change"
            //  )

            // TODO we skip the rest for now(?)
            return
        }

        var enumCaseChanges: [EnumCaseChange] = []
        let enumCasesComparator = EnumCasesComparator(lhs: lhs.enumCases, rhs: rhs.enumCases)
        enumCasesComparator.compare(context, &enumCaseChanges)
        results.append(contentsOf: enumCaseChanges.map { change in
            .update(
                id: lhs.deltaIdentifier,
                updated: .case(case: change),
                breaking: change.breaking,
                solvable: change.solvable
            )
        })
    }
}


// TODO own file!
private struct EnumCasesComparator: Comparator {
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
                    similarity: relaxedMatching.similarity
                    // TODO includeProviderSupport: includeProviderSupport
                ))

                if candidate.rawValue != relaxedMatching.element.rawValue {
                    results.append(.update(
                        id: candidate.deltaIdentifier,
                        updated: .rawValueType(from: candidate.rawValue, to: relaxedMatching.element.rawValue)
                    ))
                }
            }
        }

        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            results.append(.removal(
                id: removal.deltaIdentifier,
                solvable: true
                // TODO includeProviderSupport: includeProviderSupport
            ))
        }

        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition
                // TODO includeProviderSupport: includeProviderSupport
            ))
        }
        
        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched}),
               lhs.rawValue != rhs.rawValue {
                results.append(.update(
                    id: lhs.deltaIdentifier,
                    updated: .rawValueType(from: lhs.rawValue, to: rhs.rawValue)
                ))
            }
        }
    }
}
