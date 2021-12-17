//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ModelComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation

    func compare(_ context: ChangeComparisonContext, _ results: inout [ModelChange]) {
        // TODO only compare enum or objects?
        //  guard lhs.rootType == rhs.rootType, [TypeInformation.RootType.enum, .object].contains(lhs.rootType) else

        if lhs.rootType != rhs.rootType {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .rootType(from: lhs.rootType, to: rhs.rootType, newModel: rhs),
                breaking: true,
                solvable: false
            ))

            // we can't compare two types with different root type
            return
        }
        
        if lhs.rootType == .object {
            let objectComparator = ObjectComparator(lhs: lhs, rhs: rhs)
            objectComparator.compare(context, &results)
        } else if lhs.rootType == .enum {
            let enumComparator = EnumComparator(lhs: lhs, rhs: rhs)
            enumComparator.compare(context, &results)
        }
    }
}
