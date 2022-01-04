//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The ``DocumentComparator`` allows to compare two `APIDocument` to uncover any changes between them.
public struct DocumentComparator {
    /// The original/base document.
    public let lhs: APIDocument
    /// The updated document.
    public let rhs: APIDocument
    /// The associated ``ChangeComparisonContext``. It is used to track any changes.
    /// Use this property to access the resulting change arrays.
    public let context: ChangeComparisonContext

    /// Initialize a new DocumentComparator.
    /// - Parameters:
    ///   - configuration: The ``CompareConfiguration`` used for the comparisons.
    ///   - lhs: The base `APIDocument`.
    ///   - rhs: The updated `APIDocument`.
    public init(configuration: CompareConfiguration? = nil, lhs: APIDocument, rhs: APIDocument) {
        self.lhs = lhs
        self.rhs = rhs
        self.context = ChangeComparisonContext(
            configuration: configuration,
            latestModels: rhs.models
        )
    }

    /// This method kicks of the comparison operations.
    /// After this method has completed, you can access the ``context`` property to acquire the results of the comparison.
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
