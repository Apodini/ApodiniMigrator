//
//  DirectoryName.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

/// An enum that defines the names of the directories of a package generated by ApodiniMigrator
public enum DirectoryName: String {
    /// Sources
    case sources = "Sources"
    /// HTTP
    case http = "HTTP"
    /// Models
    case models = "Models"
    /// Resources
    case resources = "Resources"
    /// Endpoints
    case endpoints = "Endpoints"
    /// Networking
    case networking = "Networking"
    /// Utils
    case utils = "Utils"
    /// Tests
    case tests = "Tests"
}

/// Path + DirectoryName
extension Path {
    init(_ directoryName: DirectoryName) {
        self.init(directoryName.rawValue)
    }
    
    static func + (lhs: Path, rhs: DirectoryName) -> Self {
        lhs + Path(rhs)
    }
}
