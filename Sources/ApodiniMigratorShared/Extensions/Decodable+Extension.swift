//
//  File.swift
//  
//
//  Created by Eldi Cano on 25.05.21.
//

import Foundation
import PathKit

public extension Decodable {
    static func decode(from data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
    
    static func decode(from string: String) throws -> Self {
        try decode(from: string.data(using: .utf8) ?? Data())
    }
    
    static func decode(from path: Path) throws -> Self {
        try decode(from: try path.read() as Data)
    }
}
