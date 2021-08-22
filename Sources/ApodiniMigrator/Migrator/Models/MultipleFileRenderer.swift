//
//  MultipleFileRenderer.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object to write unchanged models at a specific directory
struct MultipleFileRenderer {
    /// Swift files
    private let files: [SwiftFile]
    
    /// Initializes generator from an array of `TypeInformation` elements.
    init(_ typeInformation: [TypeInformation]) throws {
        files = typeInformation
            .map { typeInformation in
                if typeInformation.isEnum {
                    return DefaultEnumFile(typeInformation)
                } else {
                    return DefaultObjectFile(typeInformation)
                }
            }
    }
    
    /// Persists `files` at the specified directory
    /// - Parameter directory: path of directory where the files should be persisted
    /// - Throws: if the path is not a valid directory path, or if the write operation fails
    func write(at directory: Path) throws {
        try files.forEach {
            try $0.write(at: directory)
        }
    }
}
