//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents the CodingKeys enum defined inside an `ObjectFileTemplate`
struct ObjectCodingKeys: Renderable {
    /// An enumeration `typeInformation` of the object, name is always `CodingKeys`
    let codingKeysEnum: TypeInformation
    
    /// Cases of `codingKeysEnum`
    var enumCases: [EnumCase] {
        codingKeysEnum.enumCases
    }
   
    /// Initializer of the coding keys from the properties of the object
    init(_ properties: [TypeProperty], addedProperties: [TypeProperty] = [], renameChanges: [UpdateChange] = []) {
        var renames: [String: String] = [:]
        for renameChange in renameChanges {
            if case let .stringValue(oldName) = renameChange.from, case let .stringValue(newName) = renameChange.to {
                renames[oldName] = newName
            }
        }
        var allCases: [EnumCase] = addedProperties.map { .init($0.name) }
        for oldProperty in properties {
            let rawValue = renames[oldProperty.name] ?? oldProperty.name
            allCases.append(.init(oldProperty.name, rawValue: rawValue))
        }
        
        codingKeysEnum = .enum(name: .init(name: "CodingKeys"), cases: allCases.sorted(by: \.name))
    }
    
    /// Renders the content of the enum, in a non-formatted way
    func render() -> String {
        """
        private \(Kind.enum.signature.without("public ")) \(codingKeysEnum.typeName.name): String, CodingKey {
        \(enumCases.map { "case \($0.name)\($0.rawValue == $0.name ? "" : " = \($0.rawValue.doubleQuoted)")" }.lineBreaked)
        }
        """
    }
}
