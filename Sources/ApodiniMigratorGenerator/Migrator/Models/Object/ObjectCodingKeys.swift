//
//  ObjectCodingKeys.swift
//  ApodiniMigratorGenerator
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents the CodingKeys enum defined inside an object file
struct ObjectCodingKeys: Renderable {
    /// An enumeration `typeInformation` of the object, name is always `CodingKeys`
    private let codingKeysEnum: TypeInformation
    
    /// Cases of `codingKeysEnum`
    private var enumCases: [EnumCase] {
        codingKeysEnum.enumCases
    }
   
    /// Initializer of the coding keys from all properties of the object and potential renaming changes
    init(_ properties: [TypeProperty], renameChanges: [UpdateChange] = []) {
        let renames = renameChanges.reduce(into: [String: String]()) { result, current in
            if case let .stringValue(oldName) = current.from, case let .stringValue(newName) = current.to {
                result[oldName] = newName
            }
        }
        
        let allCases: [EnumCase] = properties.map { property in
            let rawValue = renames[property.name] ?? property.name
            return .init(property.name, rawValue: rawValue)
        }
        
        codingKeysEnum = .enum(name: .init(name: "CodingKeys"), cases: allCases.sorted(by: \.name))
    }
    
    /// Renders the content of the enum, in a non-formatted way
    func render() -> String {
        """
        private enum \(codingKeysEnum.typeName.name): String, CodingKey {
        \(enumCases.map { "case \($0.name)\($0.rawValue == $0.name ? "" : " = \($0.rawValue.doubleQuoted)")" }.lineBreaked)
        }
        """
    }
}
