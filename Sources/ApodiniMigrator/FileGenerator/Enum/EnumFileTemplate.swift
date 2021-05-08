//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

/// Represents an `enum` file template
struct EnumFileTemplate: FileTemplate {
    /// The `.enum` type descriptor to be rendered in this file
    let typeDescriptor: TypeDescriptor
    
    /// Kind of the object, always `.enum` if initializer does not throw
    let kind: Kind
    
    /// Enum cases of the `typeDescriptor`
    var enumCases: [EnumCase] {
        typeDescriptor.enumCases
    }
    
    /// Initializer
    /// - Parameters:
    ///     - typeDescriptor: typeDescriptor to render
    ///     - kind: kind of the object
    /// - Throws: if the type descriptor is not an enum, or kind is other than `.enum`
    init(_ typeDescriptor: TypeDescriptor, kind: Kind) throws {
        guard typeDescriptor.isEnum, kind == .enum else {
            throw FileTemplateError.incompatibleType(message: "Attempted to initialize EnumFileTemplate with a non enum TypeDescriptor \(typeDescriptor.rootType)")
        }
        
        self.typeDescriptor = typeDescriptor
        self.kind = kind
    }
    
    /// Renders and formats the `typeDescriptor` in an enum swift file compliant way
    func render() -> String {
        """
        \(fileComment)
        
        \(Import(.foundation).render())
        
        \(markComment(.signature))
        \(kind.signature) \(typeNameString): String, Codable {
        \(enumCases.map { "case \($0.name.value)" }.withBreakingLines())
        }
        """.formatted(with: IndentationFormatter.self)
    }
}
