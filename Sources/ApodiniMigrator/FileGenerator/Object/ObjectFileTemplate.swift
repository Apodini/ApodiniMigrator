//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents an `object` file template
struct ObjectFileTemplate: FileTemplate {
    /// Type descriptor to be rendered in this file
    let typeDescriptor: TypeDescriptor
    
    /// Kind of the object, either `struct` or `class`
    let kind: Kind
    
    /// Properties of the object
    let properties: [TypeProperty]
    
    /// CodingKeys enum of the object
    var codingKeysEnum: ObjectCodingKeys {
        .init(properties)
    }
    
    /// Encoding method of the object
    var encodingMethod: EncodingMethod {
        .init(properties)
    }
    
    /// Decoder initializer of the object
    var decoderInitializer: DecoderInitializer {
        .init(properties)
    }
    
    /// Initializer
    /// - Parameters:
    ///     - typeDescriptor: typeDescriptor to render
    ///     - kind: kind of the object
    /// - Throws: if the type descriptor is not an object, or kind is other than `class` or `struct`
    init(_ typeDescriptor: TypeDescriptor, kind: Kind = .struct) throws {
        guard typeDescriptor.isObject, [.struct, .class].contains(kind) else {
            throw FileTemplateError.incompatibleType(message: "Attempted to initialize ObjectFileTemplate with a non object TypeDescriptor \(typeDescriptor.rootType)")
        }
        self.typeDescriptor = typeDescriptor
        self.kind = kind
        self.properties = typeDescriptor.objectProperties
    }
    
    /// Renders and formats the `typeDescriptor` in a swift file compliant way
    func render() -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())
        
        \(markComment(.signature))
        \(kind.signature) \(typeNameString): Codable {
        \(markComment(.codingKeys))
        \(codingKeysEnum.render())
        
        \(markComment(.properties))
        \(properties.map { $0.propertyLine }.withBreakingLines())
        
        \(markComment(.encodable))
        \(encodingMethod.render())
        
        \(markComment(.decodable))
        \(decoderInitializer.render())
        }
        """.formatted(with: IndentationFormatter.self)
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered under the list of properties of the object
    var propertyLine: String {
        "let \(name.value): \(type.propertyTypeString)"
    }
}
