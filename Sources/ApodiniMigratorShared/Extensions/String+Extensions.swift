//
//  String+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

public extension String {
    /// Line break
    static var lineBreak: String {
        "\n"
    }
    
    /// Double line break
    static var doubleLineBreak: String {
        .lineBreak + .lineBreak
    }
    
    /// `self` wrapped with double quotes
    var doubleQuoted: String {
        "\"\(self)\""
    }
    
    /// `self` wrapped with single quotes
    var singleQuoted: String {
        "\'\(self)\'"
    }
    
    /// Returns a version of self without the last question mark if present
    var dropQuestionMark: String {
        if last == "?" {
            return String(dropLast())
        }
        return self
    }
    
    /// Return the string with an uppercased first character
    var upperFirst: String {
        if let first = first {
            return first.uppercased() + dropFirst()
        }
        return self
    }
    
    /// Return the string with a lowercased first character
    var lowerFirst: String {
        if let first = first {
            return first.lowercased() + dropFirst()
        }
        return self
    }
    
    /// Path out of `self`
    var asPath: Path {
        Path(self)
    }
    
    /// Splits the string by a character and returns the result as a String array
    func split(character: Character) -> [String] {
        split(separator: character).map { String($0) }
    }
    
    /// Splits `self` by the passed string
    /// - Parameters:
    ///      - string: separator
    ///      - ignoreEmptyComponents: flag whether empty components should be ignored, `false` by default
    /// - Returns: the array of string components
    func split(string: String, ignoreEmptyComponents: Bool = false) -> [String] {
        components(separatedBy: string).filter { ignoreEmptyComponents ? !$0.isEmpty : true }
    }
    
    /// Returns the lines of a string
    func lines() -> [String] {
        split(string: .lineBreak)
    }
    /// Returns lines of self separated by `\n`, and trimming whitespace characters
    func sanitizedLines() -> [String] {
        // splitting the string, empty lines are mapped into empty string array elements
        split(string: .lineBreak).reduce(into: [String]()) { result, current in
            let trimmed = current.trimmingCharacters(in: .whitespaces)
            if !(result.last?.isEmpty == true && trimmed.isEmpty) { // not allowing double empty lines
                result.append(trimmed)
            }
        }
    }
    
    /// Replaces occurrencies of `string` with an empty string
    func without(_ string: String) -> String {
        with("", insteadOf: string)
    }
    
    /// Replaces occurrencies of `target` with `replacement`
    func with(_ replacement: String, insteadOf target: String) -> String {
        replacingOccurrences(of: target, with: replacement)
    }
}

public extension Collection where Element == String {
    /// Joins elements with a `\n`
    var lineBreaked: String {
        joined(separator: .lineBreak)
    }
}
