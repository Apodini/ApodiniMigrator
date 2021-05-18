//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation

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
    
    /// Resource
    var name: String { rawValue.upperFirst }
    var bundle: Bundle { .module }
}

// MARK: - Placeholders
extension Template {
    static let packageName = "___PACKAGE_NAME___"
    static let decoderDate = "___decoder___date___"
    static let decoderData = "___decoder___data___"
    static let encoderDate = "___encoder___date___"
    static let encoderData = "___encoder___data___"
    static let serverPath = "___serverpath___"
    
}
