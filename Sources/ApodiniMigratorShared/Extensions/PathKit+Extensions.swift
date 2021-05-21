//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import PathKit

#if DEBUG
public extension Path {
    static var desktop: Path { Path("/Users/eld/Desktop") }
    static var projectRoot: Path { desktop + "mswag/ApodiniMigrator" }
    
    static func testTarget(_ file: String = #file) -> Path {
        Path(file).parent()
    }
}
#endif
