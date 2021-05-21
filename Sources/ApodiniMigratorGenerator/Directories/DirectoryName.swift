//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

public enum DirectoryName: String {
    case sources = "Sources"
    case http = "HTTP"
    case models = "Models"
    case endpoints = "Endpoints"
    case networking = "Networking"
    case utils = "Utils"
    case tests = "Tests"
}

extension Path {
    init(_ directoryName: DirectoryName) {
        self.init(directoryName.rawValue)
    }
    
    static func + (lhs: Path, rhs: DirectoryName) -> Self {
        lhs + Path(rhs)
    }
}
