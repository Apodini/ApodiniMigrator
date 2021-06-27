//
//  File.swift
//  
//
//  Created by Eldi Cano on 09.05.21.
//

import Foundation

/// An object to write unchanged models at a specific directy
struct MultipleFileGenerator {
    /// Swift files
    let files: [SwiftFileTemplate]
    
    /// Initializes generator from an array of `TypeInformation` elements.
    init(_ typeInformation: [TypeInformation]) throws {
        files = typeInformation
            .map { typeInformation in
                if typeInformation.isEnum {
                    return EnumFileTemplate(typeInformation)
                } else {
                    return ObjectFileTemplate(typeInformation)
                }
            }
    }
    
    /// Persists `files` at the specified directory. Additionally it creates the directory if it does not exist
    /// - Parameter directory: path of directory where the files should be persisted
    /// - Throws: if the path is not a valid directory path, or if the write operation fails
    func write(at directory: Path) throws {
        if !directory.exists {
            try directory.mkpath()
        }
        
        try files.forEach {
            try $0.write(at: directory)
        }
    }
}
