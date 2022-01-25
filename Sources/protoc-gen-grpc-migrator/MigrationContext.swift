//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

struct MigrationContext {
    /// The base `APIDocument`
    public let document: APIDocument
    /// The `MigrationGuide`
    public let migrationGuide: MigrationGuide
    ///
    public let typeStore: TypesStore

    public let newlyCreatedModels: [TypeInformation]

    // TODO /// This is a custom TypeStore we maintain.
    //    /// Sole purpose is to restore TypeInformation references contained in the `MigrationGuide`.
    //    /// Newly added models in the `MigrationGuide`

    public init(document: APIDocument, migrationGuide: MigrationGuide) {
        var typeStore = document.typeStore
        var document = document
        var migrationGuide = migrationGuide

        // we need to add all newly added types to the typeStore!
        for change in migrationGuide.modelChanges {
            guard let addition = change.modeledAdditionChange else {
                continue
            }

            _ = typeStore.store(addition.added)
        }

        let combination = GRPCMethodParameterCombination(typeStore: typeStore)
        document.combineEndpointParametersIntoWrappedType(
            considering: &migrationGuide,
            using: combination
        )

        self.document = document
        self.migrationGuide = migrationGuide
        self.typeStore = typeStore
        self.newlyCreatedModels = combination.newlyCreatedModels
    }
}
