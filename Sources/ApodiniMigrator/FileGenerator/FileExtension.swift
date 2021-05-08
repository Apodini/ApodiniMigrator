//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represent different cases of file extensions
enum FileExtension: CustomStringConvertible {
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
    var description: String {
        switch self {
        case .markdown: return "md"
        case .json: return "json"
        case .swift: return "swift"
        case .text: return "txt"
        case let .other(value): return value
        }
    }
}
