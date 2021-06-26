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
    
    let annotation: Annotation?
    
    private var annotationComment: String {
        if let annotation = annotation {
            return annotation.comment + .lineBreak
        }
        return ""
    }
    
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
    ///     - annotation: an annotation on the object, e.g. if the model is not present in the new version anymore
    init(_ typeInformation: TypeInformation, annotation: Annotation? = nil) {
        self.typeInformation = typeInformation
        self.kind = .struct
        self.properties = typeInformation.objectProperties.sorted(by: \.name)
        self.annotation = annotation
    }
    
    private func header() -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(annotationComment)\(kind.signature) \(typeNameString): Codable {
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
