//
//  Template.swift
//  ApodiniMigratorGenerator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ApodiniMigrator

/// Resources added to the client library
enum Resources: String {
    case jsScripts = "js-convert-scripts.json"
    case jsonValues = "json-values.json"
}

enum Template: String, Resource {
    case package
    case readme
    case apodiniError
    case hTTPAuthorization
    case hTTPHeaders
    case hTTPMethod
    case parameters
    case handler
    case networkingService
    case utils
    case testFile
    case xCTestManifests
    case linuxMain
    
    static var httpTemplates: [Template] {
        [.apodiniError, .hTTPAuthorization, .hTTPHeaders, .hTTPMethod, .parameters]
    }
    
    /// Resource
    var name: String { rawValue.upperFirst }
    var bundle: Bundle { .module }
    
    var projectFileExtension: FileExtension {
        switch self {
        case .readme: return .markdown
        default: return .swift
        }
    }
    
    var projectFileName: String {
        name + projectFileExtension
    }
}


extension Path {
    static func + (lhs: Path, rhs: Template) -> Self {
        lhs + rhs.projectFileName
    }
}

// MARK: - Placeholders
extension Template {
    static let packageName = "___PACKAGE_NAME___"
    static let encoderConfiguration = "___encoder___configuration___"
    static let decoderConfiguration = "___decoder___configuration___"
    static let serverPath = "___serverpath___"
}
