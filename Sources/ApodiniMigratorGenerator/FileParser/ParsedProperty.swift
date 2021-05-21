//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

/// A parsed proeprty from the swift file
struct ParsedProperty: Equatable, CustomStringConvertible {
    /// name of the property
    let name: String
    /// The raw string of the type
    var type: String
    
    /// Description
    var description: String {
        "let \(name): \(type)"
    }
    
    /// Initializes an instance from a string line of the file
    /// Returns `nil`if the line does not correspond to the format of a property
    /// - Note Initializer is used in sections of the file where we know for sure that the lines correspond to a property
    init?(from line: String) {
        if line.contains("let ") || line.contains("var ") {
            let sanitized = line
                .without("let ")
                .without("var ")
                .split(character: ":")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            guard sanitized.count == 2, let propertyName = sanitized.first, let typeName = sanitized.last else {
                return nil
            }
            self.name = propertyName
            self.type = typeName
        } else {
            return nil
        }
    }
}
