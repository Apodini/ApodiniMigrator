//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

#if DEBUG
extension Path {
    static var desktop: Path { Path("/Users/eld/Desktop") }
    static var projectRoot: Path { desktop + "mswag/ApodiniMigrator" }
    
    static func testTarget(_ file: String = #file) -> Path {
        Path(file).parent()
    }
}
#endif

extension Path {
    /// Indicates whether the path corresponds to a file with the corresponding extension
    func `is`(_ fileExtension: FileExtension) -> Bool {
        `extension` == fileExtension.description
    }
}
