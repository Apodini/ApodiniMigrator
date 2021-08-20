//
//  File.swift
//  
//
//  Created by Eldi Cano on 20.08.21.
//

import Foundation
import ApodiniMigrator

enum Documents: String, Resource {
    case v1 = "api_qonectiq1.0.0"
    case v2 = "api_qonectiq2.0.0"
    case migrationGuide = "migration_guide"
    
    var fileExtension: FileExtension { .json }
    
    var name: String { rawValue }
    
    var bundle: Bundle { .module }
}
