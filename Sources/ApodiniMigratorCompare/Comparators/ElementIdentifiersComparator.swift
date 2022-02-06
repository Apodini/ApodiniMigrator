//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
// TODO move file!

public struct ElementIdentifiersComparator: Comparator {
    public let lhs: [AnyElementIdentifier]
    public let rhs: [AnyElementIdentifier]

    public init(lhs: [AnyElementIdentifier], rhs: [AnyElementIdentifier]) {
        self.lhs = lhs
        self.rhs = rhs
    }

    func compare(_ context: ChangeComparisonContext, _ results: inout [ElementIdentifierChange]) {
        compare(&results)
    }

    public func compare(_ results: inout [ElementIdentifierChange]) {
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
               let rhs = rhs.first(where: { $0.deltaIdentifier == matched }),
               lhs.value != rhs.value {
                results.append(.update(
                    id: lhs.deltaIdentifier,
                    updated: .init(from: lhs, to: rhs)
                ))
            }
        }
    }
}
