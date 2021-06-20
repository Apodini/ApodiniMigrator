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
    var encodable: [String]
    /// The section containing the `init(from decoder: Decoder)` initializer
    var decodable: [String]
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
        let lines = try path.read().sanitizedLines()
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
                    return codingKeys.replacingOccurrences(of: line, with: parsed.description)
                }
            }
    }
    
    mutating func addCodingKeyCase(name: String) {
        if let last = codingKeys.last(where: { $0.contains("case ") }), let index = codingKeys.firstIndex(of: last) {
            return codingKeys.insert("case \(name) = \(name.doubleQuoted)", at: index + 1)
        }
    }
    
    mutating func changedType(of property: String) {
        if let caseName = parsedCodingKeysCases.firstMatch(on: \.rawValue, with: property)?.caseName {
            if let line = encodable.first(where: { $0.contains("forKey: .\(caseName)") }) {
                encodable.replacingOccurrences(of: line, with: "try container.encode(\("hello world".doubleQuoted), forKey: .\(caseName))")
            }
        }
    }
}
