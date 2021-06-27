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
    
    let annotation: Annotation?
    
    private var annotationComment: String {
        if let annotation = annotation {
            return annotation.comment + .lineBreak
        }
        return ""
    }
    
    let rawValueType: RawValueType
    
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
    ///     - annotation: an annotation on the object, e.g. if the model is not present in the new version anymore
    init(_ typeInformation: TypeInformation, annotation: Annotation? = nil) {
        guard typeInformation.isEnum, let rawValueType = typeInformation.rawValueType else {
            fatalError("Attempted to initialize EnumFileTemplate with a non enum TypeInformation \(typeInformation.rootType)")
        }
        
        self.typeInformation = typeInformation
        self.kind = .enum
        self.annotation = annotation
        self.enumCases = typeInformation.enumCases.sorted(by: \.name)
        self.rawValueType = rawValueType
    }
    
    /// Renders and formats the `typeInformation` in an enum swift file compliant way
    func render() -> String {
        """
        \(fileComment)
        
        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(annotationComment)\(kind.signature) \(typeNameString): String, Codable, CaseIterable {
        \(enumCases.map { "case \($0.name)" }.lineBreaked)

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
