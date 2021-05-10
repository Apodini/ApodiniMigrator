//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

/// A parsed enum case from the swift file
struct ParsedEnumCase: Equatable, CustomStringConvertible {
    /// case name
    let caseName: String
    /// raw value assigned to the case
    var rawValue: String
    
    /// Description
    var description: String {
        "case \(caseName) = \(rawValue.asString)"
    }
    
    /// Initializes an instance from a string line of the file
    /// Returns `nil`if the line does not correspond to the format of a case
    /// - Note Initializer is used in sections of the file where we know for sure that the lines correspond to cases
    init?(from line: String) {
        if line.contains("case ") {
            let sanitized = line
                .without("case ")
                .without("\"")
                .split(character: "=")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            guard sanitized.count == 2, let caseName = sanitized.first, let rawValue = sanitized.last else {
                return nil
            }
            self.caseName = caseName
            self.rawValue = rawValue
        } else {
            return nil
        }
    }
    
    /// Updates the `rawValue` of `self`
    mutating func update(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// An enum model file parser
struct EnumFileParser: FileParser {
    /// The path where the file is located
    let path: Path
    /// String array of the header of the file
    var header: [String]
    /// The section that contains the cases of the enum
    var cases: [String]
    /// The section containing the `encode(to:)` method and `init(from:)` initializer
    let codable: [String]
    /// The section that contains `encodableValue()` method
    var utils: [String]
    /// The string line inside of `encodableValue()`, method that holds the deleted cases
    var deletedCasesLine: String
    /// The parsed cases of the enum
    var parsedCases: [ParsedEnumCase] {
        cases.compactMap { ParsedEnumCase(from: $0) }
    }
    
    /// Parsed deleted cases of the enum inside of `encodableValue()` method
    var deletedCases: [ParsedEnumCase] {
        parsedCases.filter { deletedCasesLine.contains(".\($0.caseName)") }
    }
    
    /// Initializes the parser with a file at the specified path
    init(path: Path) throws {
        self.path = path
        let content: String = try path.read()
        let lines = content.sanitizedLines()
        header = Self.sublines(in: lines, to: .model)
        cases = Self.sublines(in: lines, from: .model, to: .encodable)
        codable = Self.sublines(in: lines, from: .encodable, to: .utils)
        utils = Self.sublines(in: lines, from: .utils)
        self.deletedCasesLine = Self.resolveDeletedCasesLine(from: utils)
    }
    
    /// Static method to retrieve the deleted cases line inside of `encodableValue()` method
    private static func resolveDeletedCasesLine(from lines: [String]) -> String {
        if let deletedCasesLine = lines.first(where: { $0.contains(EnumEncodeValueMethod.base) }) {
            return deletedCasesLine
        } else {
            fatalError("The enum file is malformed")
        }
    }
    
    /// Saves and persists the updated file content
    func save() throws {
        let reconstructed = [
            header,
            cases,
            codable,
            utils
        ]
        .flatMap { $0 }
        .withBreakingLines()
        .formatted(with: IndentationFormatter.self)
        
        try path.write(reconstructed)
    }
    
    /// Handles the rename of a `case`
    mutating func rename(case: String, to newName: String) {
        cases
            .filter { $0.contains(`case`) }
            .forEach { line in
                if var parsed = ParsedEnumCase(from: line), parsed.rawValue == `case` {
                    parsed.update(rawValue: newName)
                    cases = cases.replacingOccurrences(of: line, with: parsed.description)
                }
            }
    }
    
    /// Handles the delete of a `case`
    mutating func deleted(case: String) {
        if let affectedCase = parsedCases.first(where: { $0.rawValue == `case` }) {
            var updated = deletedCases.map { $0.caseName }
            updated.append(affectedCase.caseName)
            utils = utils.replacingOccurrences(
                    of: deletedCasesLine,
                    with: "\(EnumEncodeValueMethod.base)[\(updated.map { ".\($0)" }.joined(separator: ", "))]"
                )
        }
    }
    
    /// Handles adding of a new `case`
    mutating func added(case: String) {
        guard let recovered = deletedCases.first(where: { $0.caseName == `case` }) else {
            return
        }
        var deletedCases = self.deletedCases.filter { $0 != recovered }
        utils = utils.replacingOccurrences(
            of: deletedCasesLine,
            with: "\(EnumEncodeValueMethod.base)[\(deletedCases.map { ".\($0.caseName)" }.joined(separator: ", "))]"
        )
    }
}

protocol FileParser {}

extension FileParser {
    static func sublines(in lines: [String], from: MARKCommentType? = nil, to: MARKCommentType? = nil) -> [String] {
        var fromIndex = lines.startIndex
        var toIndex = lines.endIndex
        
        if let from = from, let fromCommentIndex = lines.firstIndex(of: MARKComment(from).description) {
            fromIndex = fromCommentIndex
        }
        
        if let to = to, let toCommentIndex = lines.firstIndex(of: MARKComment(to).description) {
            toIndex = toCommentIndex
        }
        
        return Array(lines[min(fromIndex, toIndex) ..< max(fromIndex, toIndex)])
    }
}
