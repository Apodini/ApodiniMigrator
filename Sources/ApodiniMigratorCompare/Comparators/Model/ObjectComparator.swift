//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ObjectComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation

    func compare(_ context: ChangeComparisonContext, _ results: inout [ModelChange]) {
        var propertyChanges: [PropertyChange] = []
        let propertiesComparator = ObjectPropertiesComparator(lhs: lhs.objectProperties, rhs: rhs.objectProperties)
        propertiesComparator.compare(context, &propertyChanges)
        results.append(contentsOf: propertyChanges.map { change in
            .update(
                id: lhs.deltaIdentifier,
                updated: .property(property: change),
                breaking: change.breaking,
                solvable: change.solvable
            )
        })

        // TODO what is this?
        context.store(rhs: rhs)
    }
}
