//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
//

import Foundation

/// Represents an `enum` file template
struct EnumFileTemplate: SwiftFileTemplate {
    /// The `.enum` `typeInformation` to be rendered in this file
    let typeInformation: TypeInformation
    
    /// Kind of the object, always `.enum` if initializer does not throw
    let kind: Kind
    
    /// Enum cases of the `typeInformation`
    let enumCases: [EnumCase]
    
    /// Deprecated cases
    let deprecatedCases = EnumDeprecatedCases()
    
    /// Encode value method
    let encodeValueMethod = EnumEncodeValueMethod()
    
    /// Encoding method of the enum
    let enumEncodingMethod = EnumEncodingMethod()
    
    /// Decoding method of the enum
    var enumDecoderInitializer: EnumDecoderInitializer {
        .init(enumCases)
    }
    
    /// Initializer
    /// - Parameters:
    ///     - typeInformation: typeInformation to render
    ///     - kind: kind of the object
    /// - Throws: if the `typeInformation` is not an enum, or kind is other than `.enum`
    init(_ typeInformation: TypeInformation, kind: Kind = .enum) throws {
        guard typeInformation.isEnum, kind == .enum else {
            throw SwiftFileTemplateError.incompatibleType(message: "Attempted to initialize EnumFileTemplate with a non enum TypeInformation \(typeInformation.rootType)")
        }
        
        self.typeInformation = typeInformation
        self.kind = kind
        self.enumCases = typeInformation.enumCases.sorted(by: \.name)
    }
    
    /// Renders and formats the `typeInformation` in an enum swift file compliant way
    func render() -> String {
        """
        \(fileComment)
        
        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(kind.signature) \(typeNameString): String, Codable, CaseIterable {
        \(enumCases.map { "case \($0.name) = \($0.name.asString)" }.lineBreaked)

        \(MARKComment(.deprecated))
        \(deprecatedCases.render())

        \(MARKComment(.encodable))
        \(enumEncodingMethod.render())

        \(MARKComment(.decodable))
        \(enumDecoderInitializer.render())

        \(MARKComment(.utils))
        \(encodeValueMethod.render())
        }
        """
    }
}
