//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

/// An enumeration representing opening and closing curly brackets of `Swift` code blocks
private enum CurlyBracket: Character {
    case opening = "{"
    case closing = "}"
    
    /// The weight the curly bracket contributes to the `storage` of `IndentationFormatter`
    var weight: Int {
        self == .opening ? 1 : -1
    }
}

/// An indentation swift file formatter.
/// The result of `format(_:)` is the one obtained by `(Command+A, Control+I)` `Xcode` command combinations.
/// Additionally the formatter replaces multiple empty lines with a single one.
struct IndentationFormatter: SwiftFileFormatter {
    /// Difference between counts of visited opening and closing brackets.
    /// For compilable swift files, storage is always greater than zero
    private var storage = 0
    
    /// The indentation to be applied in a line based on the state of the storage
    private var currentIndentation: Indentation {
        guard storage >= 0 else {
            fatalError("The swift file is malformed")
        }
        return .init(UInt(storage))
    }
    
    /// Updates the storage with the difference between counts of opening and closing brackets in `line`
    /// - Parameter line: the line to be processed
    /// - Returns: If `line` contains only one closing curly bracket, returns a `.closing`, otherwise `nil`
    private mutating func updateStorage(with line: String) -> CurlyBracket? {
        // ignoring comments (not considering /***/ comments though)
        if !line.hasPrefix("//") {
            let curlyBrackets = line.compactMap { CurlyBracket(rawValue: $0) }
            storage += curlyBrackets.reduce(0) { $0 + $1.weight }
            // if encountered a line with a single closing bracket, return it
            // needed to decrease the indentation level for `line`
            if curlyBrackets == [.closing] {
                return .closing
            }
        }
        return nil
    }
    
    /// Formats content with `(Command+A, Control+I)` `Xcode` command combinations
    /// - Parameters content: string content of the swift file
    /// - Returns the formatted content
    mutating func format(_ content: String) -> String {
        content.sanitizedLines().reduce(into: "") { result, line in
            var indentation = currentIndentation
            if updateStorage(with: line) == .closing {
                indentation.dropLevel()
            }
            result += indentation + line + .lineBreak
        }
    }
    
    /// Formats content at the specified path with `(Command+A, Control+I)` `Xcode` command combinations
    /// - Parameters path: Path where the swift file is located
    /// - Throws if the read operation failed
    /// - Note results in fatalError if path does not exists, or if not a swift file
    /// - Returns the formatted content
    mutating func format(_ path: Path) throws -> String {
        guard path.exists, path.lastComponent.hasSuffix(".swift") else {
            fatalError("Invalid swift file path: \(path.string)")
        }
        return format(try path.read())
    }
}
