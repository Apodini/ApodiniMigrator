//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represent different cases of file extensions
public enum FileExtension: CustomStringConvertible {
    /// Markdown
    case markdown
    /// JSON
    case json
    /// Swift
    case swift
    /// Text
    case text
    /// Other
    case other(String)
    
    /// String representation this extension
    public var description: String {
        switch self {
        case .markdown: return "md"
        case .json: return "json"
        case .swift: return "swift"
        case .text: return "txt"
        case let .other(value): return value
        }
    }
}

public extension String {
    static func + (lhs: Self, rhs: FileExtension) -> Self {
        lhs + "." + rhs.description
    }
}

public extension Path {
    /// Indicates whether the path corresponds to a file with the corresponding extension
    func `is`(_ fileExtension: FileExtension) -> Bool {
        `extension` == fileExtension.description
    }
    
    /// Returns all swift files in `self` and in subdirectories of `self`
    func recursiveSwiftFiles() -> [Path] {
        guard isDirectory else {
            return []
        }
        return (try? recursiveChildren().filter { $0.is(.swift) }) ?? []
    }
}
