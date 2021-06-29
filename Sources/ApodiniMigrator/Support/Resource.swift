//
//  Resource.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A protocol to allow manipulation of bundle resources
/// Conforming types should specify the `Bundle` where the resources are stored and the name of the file
/// By default `fileExtension` is set to `markdown`. `content()` and `data()` functions also provide default implementations
public protocol Resource {
    /// File extension of this resource
    var fileExtension: FileExtension { get }
    /// Name of the resource file (without extension)
    var name: String { get }
    /// Bundle where this resource is stored
    var bundle: Bundle { get }
    
    /// The read operations of these functions are performed from the `bundle`
    /// Returns string content of the resource
    func content() -> String
    /// Returns the raw data of this resource.
    func data() throws -> Data
}

/// Default internal implementations
extension Resource {
    /// name of the file
    var fileName: String {
        "\(name).\(fileExtension.description)"
    }
    
    /// url of the file
    var fileURL: URL {
        guard let fileURL = bundle.url(forResource: name, withExtension: fileExtension.description) else {
            fatalError("Resource \(name) not found")
        }
        
        return fileURL
    }
    
    /// replaces the `content()` ocurrencies of `target` with `replacement`
    func replaceOccurrencies(of target: String, with replacement: String) -> String {
        content().replacingOccurrences(of: target, with: replacement)
    }
}

/// Default public implementations
public extension Resource {
    /// file extension
    var fileExtension: FileExtension { .markdown }
    
    /// string content of the file
    func content() -> String {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("Failed to read the resource")
        }
        let lines = content.sanitizedLines()
        return lines.last?.isEmpty == true ? (lines.dropLast().joined(separator: .lineBreak)) : content
    }
    
    /// raw data content of the file
    func data() throws -> Data {
        try Data(contentsOf: fileURL)
    }
}
