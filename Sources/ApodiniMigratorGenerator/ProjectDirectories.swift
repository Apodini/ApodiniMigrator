//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import PathKit

public struct ProjectDirectories {
    public let packageName: String
    public let packagePath: Path
    
    public var root: Path {
        packagePath + Path(packageName)
    }
    public var sources: Path {
        root + Path("Sources")
    }
    
    public var target: Path {
        sources + Path(packageName)
    }
    
    public var http: Path {
        target + Path("HTTP")
    }
    
    public var models: Path {
        target + Path("Models")
    }
    
    public var endpoints: Path {
        target + Path("Endpoints")
    }
    
    public var networking: Path {
        target + Path("Networking")
    }
    
    public var utils: Path {
        target + Path("Utils")
    }
    
    public var tests: Path {
        root + Path("Tests")
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
}
