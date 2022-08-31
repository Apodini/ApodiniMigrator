//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ModelsComparator: Comparator {
    struct MatchedPairs: Hashable {
        let candidate: TypeInformation
        let relaxedMatching: TypeInformation

        func contains(_ id: DeltaIdentifier) -> Bool {
            [candidate, relaxedMatching].identifiers().contains(id)
        }
    }

    let lhs: [TypeInformation]
    let rhs: [TypeInformation]

    func compare(_ context: ChangeComparisonContext, _ results: inout [ModelChange]) {
        let matchedIds = lhs.matchedIds(with: rhs)
        let removalCandidates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }

        var pairs: Set<MatchedPairs> = []

        if context.configuration.allowTypeRename {
            for candidate in removalCandidates {
                let unmatched = additionCandidates.filter { addition in pairs.allSatisfy { !$0.contains(addition.deltaIdentifier) } }
                if let relaxedMatching = candidate.mostSimilarWithSelf(in: unmatched) {
                    results.append(.idChange(
                        from: candidate.deltaIdentifier,
                        to: relaxedMatching.element.deltaIdentifier,
                        similarity: relaxedMatching.similarity
                    ))

                    pairs.insert(.init(candidate: candidate, relaxedMatching: relaxedMatching.element))
                }
            }

            // ensuring to have registered potential type renamings before comparing
            pairs.forEach {
                let modelComparator = ModelComparator(lhs: $0.candidate, rhs: $0.relaxedMatching)
                modelComparator.compare(context, &results)
            }
        }

        for removal in removalCandidates where !pairs.contains(where: { $0.contains(removal.deltaIdentifier) }) {
            results.append(.removal(
                id: removal.deltaIdentifier
            ))
        }

        for addition in additionCandidates where !pairs.contains(where: { $0.contains(addition.deltaIdentifier) }) {
            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition.referencedProperties(),
                breaking: false
            ))
        }
        
        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched }) {
                let modelComparator = ModelComparator(lhs: lhs, rhs: rhs)
                modelComparator.compare(context, &results)
            }
        }
    }
}
