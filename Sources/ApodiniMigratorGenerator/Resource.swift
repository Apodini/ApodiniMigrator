//
//  File.swift
//  
//
//  Created by Eldi Cano on 18.05.21.
//

import Foundation
import ApodiniMigrator
import PathKit

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
    var fileName: String {
        "\(name).\(fileExtension.description)"
    }
    
    var fileURL: URL {
        guard let fileURL = bundle.url(forResource: name, withExtension: fileExtension.description) else {
            fatalError("Resource \(name) not found")
        }
        
        return fileURL
    }
    
    func replaceOccurrencies(of target: String, with replacement: String) -> String {
        content().replacingOccurrences(of: target, with: replacement)
    }
    
    func write(_ content: String, file: String) throws {
//        var path = Path(file)
//        
//        path.assert()
//        
//        path.cdResources()
//        
//        let children = path.children()
//        
//        guard let resourcePath = children.first(where: { $0.last == fileName }) else {
//            return
//        }
//        
//        try content.write(to: resourcePath.url, atomically: true, encoding: .utf8)
    }
}

/// Default public implementations
public extension Resource {
    var fileExtension: FileExtension { .markdown }
    
    func content() -> String {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("Failed to read the resource")
        }
        return content
    }
    
    func data() throws -> Data {
        try Data(contentsOf: fileURL)
    }
}
