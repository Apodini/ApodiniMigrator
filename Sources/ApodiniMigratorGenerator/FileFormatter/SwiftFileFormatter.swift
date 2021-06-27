//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

/// A protocol to format swift files
public protocol SwiftFileFormatter {
    /// Initializer
    init()
    
    /// Formats content
    /// - Parameters content: string content of the swift file
    /// - Returns the formatted content
    mutating func format(_ content: String) -> String
    
    /// Formats content at the specified path
    /// - Parameters path: Path where the swift file is located
    /// - Throws if invalid path, or if the read operation failed
    mutating func format(_ path: Path) throws
}

public extension String {
    /// Returns a formatted version of `self` by a formatterType
    func formatted<S: SwiftFileFormatter>(with formatterType: S.Type) -> String {
        var formatter = formatterType.init()
        return formatter.format(self)
    }
    
    /// Returns an indentation formatted version of `self`
    func indentationFormatted() -> String {
        formatted(with: IndentationFormatter.self)
    }
}

public extension Path {
    /// Returns a formatted version of the string content of the path by a formatterType
    func formatted<S: SwiftFileFormatter>(with formatterType: S.Type) throws {
        var formatter = formatterType.init()
        return try formatter.format(self)
    }
}
