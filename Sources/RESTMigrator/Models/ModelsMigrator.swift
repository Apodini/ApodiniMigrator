//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MigratorAPI

/// An object that handles / triggers the migrated rendering of enums and objects of the client library
struct ModelsMigrator: LibraryComposite {
    /// Changed models of the client library
    private let changedModels: [TypeInformation]
    /// Unchanged models of the client library
    private let unchangedModels: [TypeInformation]
    /// All changes of the migration guide with element either an enum or an object
    private let modelChanges: [Change]

    /// Initializer for a new instance
    init(oldModels: [TypeInformation], addedModels: [TypeInformation], modelChanges: [Change]) {
        let changedIds = modelChanges.map { $0.elementID }.unique()

        var unchangedModels = Set(addedModels)
        var changedModels: Set<TypeInformation> = []

        for old in oldModels {
            if changedIds.contains(old.deltaIdentifier) {
                changedModels.insert(old)
            } else {
                unchangedModels.insert(old)
            }
        }

        self.changedModels = changedModels.asArray
        self.unchangedModels = unchangedModels.asArray

        self.modelChanges = modelChanges
    }

    var content: [LibraryComponent] {
        // generate non-modified types without any special migration
        for unchangedModelInformation in unchangedModels {
            if unchangedModelInformation.isEnum {
                DefaultEnumFile(unchangedModelInformation)
            } else { // TODO else if isObject?
                DefaultObjectFile(unchangedModelInformation)
            }
        }

        for changedModel in changedModels {
            let changes = modelChanges.filter { change in
                change.elementID == changedModel.deltaIdentifier
            }

            if changedModel.isEnum {
                EnumMigrator(changedModel, changes: changes)
            } else if changedModel.isObject {
                ObjectMigrator(changedModel, changes: changes)
            }
        }
    }
}
