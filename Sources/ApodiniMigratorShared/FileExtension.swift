//
//  FileExtension.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

/// Represent different cases of file extensions
public enum FileExtension: CustomStringConvertible {
    /// Markdown
    case markdown
    /// JSON
    case json
    /// YAML
    case yaml
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
        case .yaml: return "yaml"
        case .swift: return "swift"
        case .text: return "txt"
        case let .other(value): return value
        }
    }
}

public extension String {
    /// Returns lhs after appending `.` and `description` of `rhs`
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
