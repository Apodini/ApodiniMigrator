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
    let document: APIDocument
    /// The `MigrationGuide`
    let migrationGuide: MigrationGuide
    /// This is a custom TypeStore we maintain which combines the `TypeStore` from the `APIDocument`
    /// and all types which are newly introduced via the `MigrationGuide`.
    /// This TypeStore also contains the wrapper types created through the `ParameterCombination`.
    let typeStore: TypesStore
    /// Array of `TypeInformation` of Endpoint Parameter wrapper types which were newly and dynamically created
    /// AND got added to the `APIDocument` `TypeStore` (wrapper types derive from ADDED endpoints are stored
    /// as model additions in the MigrationGuide).
    /// The MigrationGuide might contain **property changes** for those models.
    /// NOTE: Those models are guaranteed to be **dereferenced**!
    let apiDocumentModelAdditions: [TypeInformation]

    init(document: APIDocument, migrationGuide: MigrationGuide) {
        var document = document
        var migrationGuide = migrationGuide

        // We have the following problem: with the ParameterCombination new types get added to two different places:
        // (1) the APIDocument TypeStore and (2) to the MigrationGuide through Model addition changes.
        // As our library basis is not based on the `APIDocument` but on the proto files, we need to uncover
        // which values got added to the `TypeStore` such that we can manually add it to our generated files.
        // To do this, we track the current `TypeStore` state with the means of `DeltaIdentifier`.
        let typeStoreState = Set(document.models.map { $0.deltaIdentifier })

        let combination = GRPCMethodParameterCombination(typeStore: document.typeStore)
        document.combineEndpointParametersIntoWrappedType(
            considering: &migrationGuide,
            using: combination
        )

        // Based on `typeStoreState` we derive which models got added via the ParameterCombination
        var apiDocumentModelAdditions: [TypeInformation] = []
        for model in document.models where !typeStoreState.contains(model.deltaIdentifier) {
            apiDocumentModelAdditions.append(model)
        }

        // it is important that we pull out the typeStore only after the `ParameterCombination` has run.
        // Above operation will store new types (only for the endpoints which are part of the APIDocument)
        // which will be stored there. Endpoint Parameter will have reference type.
        var typeStore = document.typeStore

        // Now we add all the newly introduced types contained in the migration guide to the custom maintained `TypeStore`.
        // This is important as e.g. newly added Endpoints will contain reference types which we need to resolved!
        for change in migrationGuide.modelChanges {
            guard let addition = change.modeledAdditionChange else {
                continue
            }

            _ = typeStore.store(addition.added)
        }

        self.document = document
        self.migrationGuide = migrationGuide
        self.typeStore = typeStore
        self.apiDocumentModelAdditions = apiDocumentModelAdditions
    }
}
