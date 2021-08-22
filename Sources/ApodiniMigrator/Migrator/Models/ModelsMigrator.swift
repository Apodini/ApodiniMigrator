//
//  ModelsMigrator.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object that handles / triggeres the migrated rendering of enums and objects of the client library
struct ModelsMigrator {
    /// Path of `Models` folder of the client library
    private let modelsPath: Path
    /// Changed models of the client library
    private let changedModels: [TypeInformation]
    /// Unchanged models of the client library
    private let unchangedModels: [TypeInformation]
    /// All changes of the migration guide with element either an enum or an object
    private let modelChanges: [Change]
    
    /// Initializer for a new instance
    init(path: Path, oldModels: [TypeInformation], addedModels: [TypeInformation], modelChanges: [Change]) {
        self.modelsPath = path
        self.modelChanges = modelChanges
        
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
    }
    
    /// Triggeres the rendering of migrated content of model files
    func migrate() throws {
        let multipleFileRenderer = try MultipleFileRenderer(unchangedModels)
        try multipleFileRenderer.write(at: modelsPath)
        
        for changedModel in changedModels {
            let changes = modelChanges.filter { $0.elementID == changedModel.deltaIdentifier }
            if changedModel.isEnum {
                let enumMigrator = EnumMigrator(enum: changedModel, changes: changes)
                try enumMigrator.write(at: modelsPath)
            } else if changedModel.isObject {
                let objectMigrator = ObjectMigrator(changedModel, changes: changes)
                try objectMigrator.write(at: modelsPath)
            }
        }
    }
}
