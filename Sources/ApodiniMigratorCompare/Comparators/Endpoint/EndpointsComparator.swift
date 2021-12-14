//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct EndpointsComparator: Comparator {
    struct MatchedPairs: Hashable {
        let candidate: Endpoint
        let relaxedMatching: Endpoint

        func contains(_ id: DeltaIdentifier) -> Bool {
            candidate.deltaIdentifier == id || relaxedMatching.deltaIdentifier == id
        }
    }

    let lhs: [Endpoint]
    let rhs: [Endpoint]

    func compare(_ context: ChangeComparisonContext, _ results: inout [EndpointChange]) {
        let matchedIds = lhs.matchedIds(with: rhs)
        let removalCandidates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }

        var pairs: Set<MatchedPairs> = []

        if context.configuration.allowEndpointIdentifierUpdate {
            for candidate in removalCandidates {
                let unmatched = additionCandidates.filter { added in pairs.allSatisfy { !$0.contains(added.deltaIdentifier) } }
                if let relaxedMatching = candidate.mostSimilarWithSelf(in: unmatched, useRawValueDistance: false) {
                    results.append(.idChange(
                        from: candidate.deltaIdentifier,
                        to: relaxedMatching.element.deltaIdentifier,
                        similarity: relaxedMatching.similarity
                        // includeProviderSupport: context.configuration.includeProviderSupport
                    ))

                    pairs.insert(.init(candidate: candidate, relaxedMatching: relaxedMatching.element))
                }
            }

            pairs.forEach {
                let endpointComparator = EndpointComparator(lhs: $0.candidate, rhs: $0.relaxedMatching)
                endpointComparator.compare(context, &results)
            }
        }

        let includeProviderSupport = context.configuration.allowEndpointIdentifierUpdate && context.configuration.includeProviderSupport

        for removal in removalCandidates where !pairs.contains(where: { $0.contains(removal.deltaIdentifier) }) {
            results.append(.removal(
                id: removal.deltaIdentifier
                // TODO includeProviderSupport: includeProviderSupport
            ))
        }

        for addition in additionCandidates where !pairs.contains(where: { $0.contains(addition.deltaIdentifier) }) {
            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition.referencedTypes()
                // TODO includeProviderSupport: includeProviderSupport
            ))
        }
        
        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched}) {
                let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs)
                endpointComparator.compare(context, &results)
            }
        }
    }
}
