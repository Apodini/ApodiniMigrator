//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation


/// represents specification type as stated in migration guide, currently only `OpenAPI` supported
enum SpecificationType: String, Value {
    case apodini = "Apodini"
    case openapi = "OpenAPI"
}
