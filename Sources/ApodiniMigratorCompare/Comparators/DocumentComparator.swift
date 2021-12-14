//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct DocumentComparator {
    let lhs: APIDocument
    let rhs: APIDocument

    func compare(_ context: ChangeComparisonContext) {
        let metaDataComparator = ServiceInformationComparator(lhs: lhs.serviceInformation, rhs: rhs.serviceInformation)
        metaDataComparator.compare(context, &context.serviceChanges)

        // TODO comment, models must be compared first, as js script uses it!
        let modelsComparator = ModelsComparator(
            lhs: .init(lhs.types.values),
            rhs: .init(rhs.types.values)
        )
        modelsComparator.compare(context, &context.modelChanges)

        let endpointsComparator = EndpointsComparator(lhs: lhs.endpoints, rhs: rhs.endpoints)
        endpointsComparator.compare(context, &context.endpointChanges)
    }
}
