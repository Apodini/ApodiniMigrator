//
//  PathKit+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import PathKit

#if DEBUG
public extension Path {
    /// :nodoc:
    static var desktop: Path { Path("/Users/eld/Desktop") }
    /// :nodoc:
    static var projectRoot: Path { desktop + "mswag/ApodiniMigrator" }
    /// :nodoc:
    static func testTarget(_ file: String = #file) -> Path {
        Path(file).parent()
    }
}
#endif
