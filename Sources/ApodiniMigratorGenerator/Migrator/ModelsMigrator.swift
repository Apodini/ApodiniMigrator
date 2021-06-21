//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

struct ModelsMigrator {
    
    let modelsPath: Path
    let changedModels: [TypeInformation]
    let unchangedModels: [TypeInformation]
    let modelChanges: [Change]
    
    init(path: Path, oldModels: [TypeInformation], addedModels: [TypeInformation], deletedModelIDs: [DeltaIdentifier], modelChanges: [Change]) {
        self.modelsPath = path
        self.modelChanges = modelChanges
        
        let changedIds = modelChanges.map { $0.element.deltaIdentifier }
        var unchangedModels: Set<TypeInformation> = Set(addedModels)
        var changedModels: Set<TypeInformation> = []
        for old in oldModels {
            if changedIds.contains(old.deltaIdentifier) {
                changedModels.insert(old)
            } else {
                unchangedModels.insert(old)
            }
        }
        self.changedModels = changedModels.asArray
        self.unchangedModels = unchangedModels.asArray.fileRenderableTypes()
    }
    
    
    func build() throws {
        let multipleFileGenerator = try MultipleFileGenerator(unchangedModels)
        try multipleFileGenerator.persist(at: modelsPath)
        
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
