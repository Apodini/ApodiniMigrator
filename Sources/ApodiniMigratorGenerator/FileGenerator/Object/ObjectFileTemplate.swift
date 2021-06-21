//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents an `object` file template
struct ObjectFileTemplate: SwiftFileTemplate {
    /// `TypeInformation` to be rendered in this file
    let typeInformation: TypeInformation
    
    /// Kind of the object, either `struct` or `class`
    let kind: Kind
    
    /// Properties of the object
    let properties: [TypeProperty]
    
    /// CodingKeys enum of the object
    var codingKeysEnum: ObjectCodingKeys {
        .init(properties)
    }
    
    /// Initializer of an object
    var objectInitializer: ObjectInitializer {
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
    ///     - typeInformation: typeInformation to render
    ///     - kind: kind of the object
    /// - Throws: if the `typeInformation` is not an object, or kind is other than `class` or `struct`
    init(_ typeInformation: TypeInformation, kind: Kind = .struct) {
        guard typeInformation.isObject, [.struct, .class].contains(kind) else {
            fatalError("Attempted to initialize ObjectFileTemplate with a non object TypeInformation \(typeInformation.rootType)")
        }
        self.typeInformation = typeInformation
        self.kind = kind
        self.properties = typeInformation.objectProperties.sorted(by: \.name)
    }
    
    private func header() -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(kind.signature) \(typeNameString): Codable {
        """
    }
    
    /// Renders and formats the `typeInformation` in a swift file compliant way
    func render() -> String {
        if properties.isEmpty {
            let content =
            """
            \(header())
            \(MARKComment(.initializer))
            public init() {}
            }
            """
            return content
        } else {
            let content =
                """
                \(header())
                \(MARKComment(.codingKeys))
                \(codingKeysEnum.render())
                
                \(MARKComment(.properties))
                \(properties.map { $0.propertyLine }.lineBreaked)

                \(MARKComment(.initializer))
                \(objectInitializer.render())
                
                \(MARKComment(.encodable))
                \(encodingMethod.render())
                
                \(MARKComment(.decodable))
                \(decoderInitializer.render())
                }
                """
            return content
        }
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered under the list of properties of the object
    var propertyLine: String {
        "public var \(name): \(type.typeString)"
    }
}
