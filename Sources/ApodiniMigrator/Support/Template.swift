//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCore

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

    var fileExtension: FileExtension {
        projectFileExtension
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
    static let serverPath = "___serverpath___" // TODO very http sepcific!!
    static let serverProtocol = "___protocol___" // TODO https???
    static let host = "___host___"
    static let port = "___port___"
}
