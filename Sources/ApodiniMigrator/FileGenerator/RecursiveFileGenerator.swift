//
//  File.swift
//  
//
//  Created by Eldi Cano on 09.05.21.
//

import Foundation

/// A protocol to persist some content at a specified directory
protocol Persistable {
    /// Persists content
    /// - Parameter directory: directory path where the content should be persisted
    /// - Throws: if write operation fails
    func persist(at directory: Path) throws
}

/// A persistable object to write swift files at a specified directory
struct RecursiveFileGenerator: Persistable {
    /// Swift files
    let files: [SwiftFileTemplate]
    
    /// Initializes generator from an array of `TypeInformation` elements.
    /// From `typeInformation` the generator retrieves all distinct `enum` and `object` types recursively
    init(_ typeInformation: [TypeInformation]) throws {
        files = try typeInformation
            .fileRenderableTypes()
            .map { typeInformation in
                if typeInformation.isEnum {
                    return try EnumFileTemplate(typeInformation)
                } else {
                    return try ObjectFileTemplate(typeInformation)
                }
            }
    }
    
    /// Initializes `self` from `anyTypes`
    init(_ anyTypes: Any.Type...) throws {
        try self.init(anyTypes.map { try TypeInformation(type: $0) })
    }
    
    /// Initializes `self` from `anyTypes`
    init(_ anyTypes: [Any.Type]) throws {
        try self.init(anyTypes.map { try TypeInformation(type: $0) })
    }
    
    /// Persists `files` at the specified directory
    /// - Parameter directory: path of directory where the files should be persisted
    /// - Throws: if the path is not a valid directory path, or if the write operation fails
    func persist(at directory: Path) throws {
        try directory.createDirectoryIfNeeded()
        
        try files.forEach {
            try $0.write(at: directory)
        }
    }
}
