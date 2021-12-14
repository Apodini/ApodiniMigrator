//
// Created by Andreas Bauer on 14.12.21.
//

import Foundation

struct IdentifiersComparator: Comparator {
    let lhs: [AnyEndpointIdentifier]
    let rhs: [AnyEndpointIdentifier]

    func compare(_ context: ChangeComparisonContext, _ results: inout [EndpointIdentifierChange]) {
        let matchedIds = lhs.matchedIds(with: rhs)
        let removalCandidates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }

        for addition in additionCandidates {
            results.append(.addition(
                id: addition.deltaIdentifier,
                added: addition,
                breaking: false,
                solvable: true
            ))
        }

        for removal in removalCandidates {
            results.append(.removal(
                id: removal.deltaIdentifier,
                removed: removal,
                breaking: true,
                solvable: false
            ))
        }

        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }),
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched}),
               lhs.value != rhs.value {
                results.append(.update(
                    id: lhs.deltaIdentifier,
                    updated: .value(from: lhs.value, to: rhs.value)
                ))
            }
        }
    }
}
