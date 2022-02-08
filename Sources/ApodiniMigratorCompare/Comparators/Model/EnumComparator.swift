//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

struct EnumComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation

    func compare(_ context: ChangeComparisonContext, _ results: inout [ModelChange]) {
        guard let lhsRawValue = lhs.rawValueType, let rhsRawValue = rhs.rawValueType else {
            fatalError("Encountered non enum when comparing enum models")
        }

        if lhsRawValue != rhsRawValue {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .rawValueType(
                    from: lhsRawValue.asReference(),
                    to: rhsRawValue.asReference()
                ),
                solvable: false
            ))

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
