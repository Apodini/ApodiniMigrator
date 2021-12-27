//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct DocumentComparator {
    public let lhs: APIDocument
    public let rhs: APIDocument
    public let context: ChangeComparisonContext

    public init(configuration: CompareConfiguration? = nil, lhs: APIDocument, rhs: APIDocument) {
        self.lhs = lhs
        self.rhs = rhs
        self.context = ChangeComparisonContext(
            configuration: configuration,
            latestModels: rhs.models
        )
    }

    public func compare() {
        let metaDataComparator = ServiceInformationComparator(lhs: lhs.serviceInformation, rhs: rhs.serviceInformation)
        metaDataComparator.compare(context, &context.serviceChanges)

        // It is important that the ModelsComparator runs before the EndpointsComparator, as this step
        // collects possible migration js scripts which are later on referenced.
        let modelsComparator = ModelsComparator(
            lhs: .init(lhs.models),
            rhs: .init(rhs.models)
        )
        modelsComparator.compare(context, &context.modelChanges)

        let endpointsComparator = EndpointsComparator(lhs: lhs.endpoints, rhs: rhs.endpoints)
        endpointsComparator.compare(context, &context.endpointChanges)
    }
}
