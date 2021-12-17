//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// An object that handles / triggers the migrated rendering of enums and objects of the client library
struct ModelsMigrator: LibraryComposite {
    /// Unchanged models of the client library. We can directly generate those.
    private let unchangedModels: [TypeInformation]

    /// Changed models of the client library. Change descriptions reside in ``modelChanges``.
    /// Models might be updated, removed or renamed.
    private let changedModels: [TypeInformation]
    /// All changes of the migration guide, describing changes of models saved in ``changedModels``.
    private let modelChanges: [ModelChange]

    init(document baseDocument: APIDocument, migrationGuide: MigrationGuide) {
        let changesIds = migrationGuide.modelChanges.map { $0.id }

        var unchangedModels: [TypeInformation] = []
        var changedModels: [TypeInformation] = []

        // new models are per definition unchanged
        let addedModels: [TypeInformation] = migrationGuide.modelChanges
            .compactMap({ $0.modeledAdditionChange })
            .map { $0.added }
        changedModels.append(contentsOf: addedModels)

        // check if the models from the base document were changed or not
        for model in baseDocument.models {
            if changesIds.contains(model.deltaIdentifier) {
                changedModels.append(model)
            } else {
                unchangedModels.append(model)
            }
        }

        self.unchangedModels = unchangedModels

        self.changedModels = changedModels
        self.modelChanges = migrationGuide.modelChanges
    }

    var content: [LibraryComponent] {
        // generate non-modified types without any special migration
        for unchangedModelInformation in unchangedModels {
            if unchangedModelInformation.isEnum {
                DefaultEnumFile(unchangedModelInformation)
            } else {
                DefaultObjectFile(unchangedModelInformation)
            }
        }

        for changedModel in changedModels {
            let changes = modelChanges.of(base: changedModel)

            if changedModel.isEnum {
                EnumMigrator(changedModel, changes: changes)
            } else if changedModel.isObject {
                ObjectMigrator(changedModel, changes: changes)
            }
        }
    }
}
