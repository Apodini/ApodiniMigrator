//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents the CodingKeys enum defined inside an `ObjectFileTemplate`
struct ObjectCodingKeys: Renderable {
    /// An enumeration type descriptor of the object, name is always `CodingKeys`
    let codingKeysEnum: TypeDescriptor
    
    /// Cases of `codingKeysEnum`
    var enumCases: [EnumCase] {
        codingKeysEnum.enumCases
    }
    
    /// Initializer of the coding keys from the properties of the object
    init(_ properties: [TypeProperty]) {
        codingKeysEnum = .enum(name: .init(name: "CodingKeys"), cases: properties.map { EnumCase($0.name.value) })
    }
    
    /// Renders the content of the enum, in a non-formatted way
    func render() -> String {
        """
        \(Kind.enum.rawValue) \(codingKeysEnum.typeName.name): String, CodingKey {
        \(enumCases.map { "case \($0.name.value)" }.withBreakingLines())
        }
        """
    }
}
