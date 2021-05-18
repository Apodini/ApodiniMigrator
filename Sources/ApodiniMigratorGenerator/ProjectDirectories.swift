//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import PathKit

struct ProjectDirectories {
    let packageName: String
    let packagePath: Path
    var root: Path {
        packagePath + Path(packageName)
    }
    var sources: Path {
        root + Path("Sources")
    }
    
    var target: Path {
        sources + Path(packageName)
    }
    
    var http: Path {
        target + Path("HTTP")
    }
    
    var models: Path {
        target + Path("Models")
    }
    
    var endpoints: Path {
        target + Path("Endpoints")
    }
    
    var networking: Path {
        target + Path("Networking")
    }
    
    var utils: Path {
        target + Path("Utils")
    }
    
    var tests: Path {
        root + Path("Tests")
    }
    
    var testsTarget: Path {
        tests + Path(packageName + "Tests")
    }
    
    init(packageName: String, packagePath: Path) {
        self.packageName = packageName
        self.packagePath = packagePath
    }
    
    func build() throws {
        try [http, models, endpoints, networking, utils, testsTarget].forEach { try $0.mkpath() }
    }
}
