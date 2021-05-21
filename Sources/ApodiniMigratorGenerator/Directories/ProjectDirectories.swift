//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation

public struct ProjectDirectories {
    public let packageName: String
    public let packagePath: Path
    
    public var root: Path {
        packagePath + Path(packageName)
    }
    
    public var sources: Path {
        root + .sources
    }
    
    public var target: Path {
        sources + Path(packageName)
    }
    
    public var http: Path {
        target + .http
    }
    
    public var models: Path {
        target + .models
    }
    
    public var endpoints: Path {
        target + .endpoints
    }
    
    public var networking: Path {
        target + .networking
    }
    
    public var utils: Path {
        target + DirectoryName.utils
    }
    
    public var tests: Path {
        root + .tests
    }
    
    public var testsTarget: Path {
        tests + Path(packageName + "Tests")
    }
    
    public init(packageName: String, packagePath: Path) {
        self.packageName = packageName
        self.packagePath = packagePath
    }
    
    public func build() throws {
        try [http, models, endpoints, networking, utils, testsTarget].forEach { try $0.mkpath() }
    }
    
    func path(of directory: DirectoryName) -> Path {
        switch directory {
        case .sources: return sources
        case .http: return http
        case .models: return models
        case .endpoints: return endpoints
        case .networking: return networking
        case .utils: return utils
        case .tests: return tests
        }
    }
}
