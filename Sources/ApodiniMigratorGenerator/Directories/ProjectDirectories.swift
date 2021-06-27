//
//  ProjectDirectories.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation

/// An object that defines project directories out of a `packageName` and a `packagePath`
public struct ProjectDirectories {
    /// Name of the package
    public let packageName: String
    /// Path where the package should be created
    /// - Note: without package name
    public let packagePath: Path
    
    /// Root directory of the package
    public var root: Path {
        packagePath + packageName
    }
    
    /// Sources directory of the package
    public var sources: Path {
        root + .sources
    }
    
    /// Target directory of the package
    public var target: Path {
        sources + packageName
    }
    
    /// `HTTP` directory of the package
    public var http: Path {
        target + .http
    }
    
    /// `Resources` directory path
    public var resources: Path {
        target + .resources
    }
    
    /// `Models` directory of the package
    public var models: Path {
        target + .models
    }
    
    /// `Endpoints` directory of the package
    public var endpoints: Path {
        target + .endpoints
    }
    
    /// `Networking` directory of the package
    public var networking: Path {
        target + .networking
    }
    
    /// `Utils` directory of the package
    public var utils: Path {
        target + DirectoryName.utils
    }
    
    /// `Tests` directory of the package
    public var tests: Path {
        root + .tests
    }
    
    /// Test target directory of the package
    public var testsTarget: Path {
        tests + Path(packageName + "Tests")
    }
    
    /// All directories of the package that contain files
    var allDirectories: [Path] {
        [http, resources, models, endpoints, networking, utils, testsTarget]
    }
    
    /// Initializes `self` out of a `packageName` and a `packagePath`
    public init(packageName: String, packagePath: Path) {
        self.packageName = packageName
        self.packagePath = packagePath
    }
    
    /// Initializes `self` out of a `packageName` and a string `packagePath`
    public init(packageName: String, packagePath: String) {
        self.packageName = packageName
        self.packagePath = packagePath.asPath
    }
    
    /// Creates empty directories of the package
    public func build() throws {
        try? root.delete()
        
        try allDirectories.forEach { try $0.mkpath() }
    }
    
    /// A util function that returns the path from a `DirectoryName`
    func path(of directory: DirectoryName) -> Path {
        switch directory {
        case .sources: return sources
        case .http: return http
        case .resources: return resources
        case .models: return models
        case .endpoints: return endpoints
        case .networking: return networking
        case .utils: return utils
        case .tests: return tests
        }
    }
}
