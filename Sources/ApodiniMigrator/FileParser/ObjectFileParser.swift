//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

/// An object model file parser
struct ObjectFileParser: FileParser {
    /// The path where the file is located
    let path: Path
    /// String array of the header of the file
    var header: [String]
    /// The section that contains the cases of the enum
    var codingKeys: [String]
    /// Properties section
    var properties: [String]
    /// Initializer section
    var initializer: [String]
    /// The section containing the `encode(to:)` method
    let encodable: [String]
    /// The section containing the `init(from decoder: Decoder)` initializer
    let decodable: [String]
    /// The sections of the file
    var sections: Sections {
        [header, codingKeys, properties, initializer, encodable, decodable]
    }
    
    /// Parsed enum cases of `CodingKeys`
    var parsedCodingKeysCases: [ParsedEnumCase] {
        codingKeys.compactMap { ParsedEnumCase(from: $0) }
    }
    
    /// Parsed properties of the file
    let parsedProperties: [ParsedProperty]
    
    /// Initializes the parser with a file at the specified path
    init(path: Path) throws {
        self.path = path
        let content: String = try path.read()
        let lines = content.sanitizedLines()
        header = Self.sublines(in: lines, to: .model)
        codingKeys = Self.sublines(in: lines, from: .model, to: .properties)
        properties = Self.sublines(in: lines, from: .properties, to: .initializer)
        initializer = Self.sublines(in: lines, from: .initializer, to: .encodable)
        encodable = Self.sublines(in: lines, from: .encodable, to: .decodable)
        decodable = Self.sublines(in: lines, from: .decodable)
        parsedProperties = properties.compactMap { ParsedProperty(from: $0) }
    }
    
    /// Handles the rename of a `property`
    mutating func renamed(property: String, to newName: String) {
        codingKeys
            .filter { $0.contains(property) }
            .forEach { line in
                if var parsed = ParsedEnumCase(from: line), parsed.rawValue == property {
                    parsed.update(rawValue: newName)
                    codingKeys = codingKeys.replacingOccurrences(of: line, with: parsed.description)
                }
            }
    }
}

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
