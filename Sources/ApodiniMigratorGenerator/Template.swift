//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import ApodiniMigrator

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
        rawValue.upperFirst + projectFileExtension
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
