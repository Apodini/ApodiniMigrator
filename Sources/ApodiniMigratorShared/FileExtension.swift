//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// Represent different cases of file extensions
public enum FileExtension: CustomStringConvertible {
    /// Markdown
    case markdown // TODO remove some cases
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
    func recursiveSwiftFiles() throws -> [Path] {
        guard isDirectory else {
            return []
        }
        return try recursiveChildren().filter { $0.is(.swift) }
    }
}
