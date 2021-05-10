//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

/// A parsed enum case from the swift file, either from a `CodingKeys` enum or a model file
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
