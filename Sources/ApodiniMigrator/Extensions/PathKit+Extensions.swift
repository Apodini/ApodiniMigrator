//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

extension Path {
    func createDirectoryIfNeeded() throws {
        if !exists {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

#if DEBUG
extension PathKit.Path {
    static var desktop: Path { Path("/Users/eld/Desktop") }
    
    static func testTarget(_ file: String = #file) -> Path {
        Path(file).parent()
    }
}
#endif
