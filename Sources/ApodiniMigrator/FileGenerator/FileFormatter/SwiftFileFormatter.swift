//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

/// A protocol to format swift files
protocol SwiftFileFormatter {
    /// Initializer
    init()
    
    /// Formats content
    /// - Parameters content: string content of the swift file
    /// - Returns the formatted content
    mutating func format(_ content: String) -> String
    
    /// Formats content at the specified path
    /// - Parameters path: Path where the swift file is located
    /// - Throws if invalid path, or if the read operation failed
    /// - Returns the formatted content
    mutating func format(_ path: Path) throws -> String
}

extension String {
    func formatted(with formatterType: SwiftFileFormatter.Type) -> String {
        var formatter = formatterType.init()
        return formatter.format(self)
    }
}

extension Path {
    func formatted(with formatterType: SwiftFileFormatter.Type) throws -> String {
        var formatter = formatterType.init()
        return try formatter.format(self)
    }
}