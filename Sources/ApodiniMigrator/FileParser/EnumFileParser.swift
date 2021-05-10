//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

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
    
    /// Sections of the file
    var sections: Sections {
        [header, cases, codable, utils]
    }
    
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
        
        utils = utils.replacingOccurrences(
            of: deletedCasesLine,
            with: "\(EnumEncodeValueMethod.base)[\(deletedCases.filter { $0 != recovered }.map { ".\($0.caseName)" }.joined(separator: ", "))]"
        )
    }
}
