//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

/// An enumeration representing opening and closing brackets (curly or rounding) of `Swift` code blocks
private enum Bracket: Int {
    case opening = 1
    case closing = -1
    
    /// Initializer of a bracket type out of a character
    init?(_ character: Character) {
        if ["{", "(", "["].contains(character) {
            self = .opening
        } else if ["}", ")", "]"].contains(character) {
            self = .closing
        } else {
            return nil
        }
    }
    
    /// The weight the bracket contributes to the `storage` of `IndentationFormatter`
    var weight: Int {
        rawValue
    }
}

/// An indentation swift file formatter.
/// The result of `format(_:)` is the one obtained by `(Command+A, Control+I)` `Xcode` command combinations.
/// Additionally the formatter replaces multiple empty lines with a single one.
public struct IndentationFormatter: SwiftFileFormatter {
    /// Difference between counts of visited opening and closing brackets.
    /// For compilable swift files, storage is always greater than zero while formatting, and zero at the end
    private var storage = 0
    
    /// The indentation to be applied in a line based on the state of the storage
    private var currentIndentation: Indentation {
        guard storage >= 0 else {
            fatalError("The swift file is malformed")
        }
        return .init(UInt(storage))
    }
    
    public init() {}
    
    /// Updates the storage with the difference between counts of opening and closing brackets in `line`
    /// - Parameter line: the line to be processed
    /// - Returns: If `line` contains only one closing bracket, returns a `.closing`, otherwise `nil`
    private mutating func updateStorage(with line: String) -> Bracket? {
        // ignoring comments (not considering /***/ comments though)
        if !line.hasPrefix("//") {
            let lineBrackets = line.compactMap { Bracket($0) }
            storage += lineBrackets.reduce(0) { $0 + $1.weight }
            // if encountered a line with a single closing bracket, return it.
            // needed to decrease the indentation level for `line`
            if lineBrackets == [.closing] || lineBrackets == [.closing, .opening] {
                return .closing
            }
        }
        return nil
    }
    
    /// Formats content with `(Command+A, Control+I)` `Xcode` command combinations
    /// - Parameters content: string content of the swift file
    /// - Returns the formatted content
    public mutating func format(_ content: String) -> String {
        let formatted = content.sanitizedLines().reduce(into: "") { result, line in
            var indentation = currentIndentation
            if updateStorage(with: line) == .closing {
                indentation.dropLevel()
            }
            result += indentation + line + .lineBreak
        }
        assert(storage == 0, "Encountered a malformed swift file. Non-balanced number of opening a closing brackets: \(abs(storage))")
        return formatted
    }
    
    /// Formats content at the specified path with `(Command+A, Control+I)` `Xcode` command combinations, and persists the changes
    /// - Parameters path: Path where the swift file is located
    /// - Throws if the read operation failed
    /// - Note results in fatalError if path does not exists, or if not a swift file
    public mutating func format(_ path: Path) throws {
        guard path.exists, path.is(.swift) else {
            fatalError("Invalid swift file path: \(path.string)")
        }
        try path.write(format(try path.read()))
    }
}
