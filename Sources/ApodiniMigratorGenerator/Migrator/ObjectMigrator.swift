//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

struct ObjectMigrator {
    let object: TypeInformation
    let changes: [Change]
    
    
    func migrate() {
        
    }
    
    func persist(at directory: Path) throws {
        migrate()
    }
}
