//
//  DefaultEnumFile.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents an `enum` file that did not got affected by any change
struct DefaultEnumFile: SwiftFile {
    /// The `.enum` `typeInformation` to be rendered in this file
    let typeInformation: TypeInformation
    
    /// Kind of the object, always `.enum`
    let kind: Kind = .enum
    
    /// An annotation comment that can be rendered in the enum declaration
    private let annotation: Annotation?
    
    /// String representation of the annotation if not nil
    private var annotationComment: String {
        if let annotation = annotation {
            return annotation.comment + .lineBreak
        }
        return ""
    }
    
    /// Raw value type of the enum
    private let rawValueType: RawValueType
    
    /// Enum cases of the `typeInformation`
    private let enumCases: [EnumCase]
    
    /// Deprecated cases
    private let deprecatedCases = EnumDeprecatedCases()
    
    /// Encode value method
    private let encodeValueMethod = EnumEncodeValueMethod()
    
    /// Encoding method of the enum
    private let enumEncodingMethod = EnumEncodingMethod()
    
    /// Decoding method of the enum
    private var enumDecoderInitializer: EnumDecoderInitializer {
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
        \(annotationComment)\(kind.signature) \(typeNameString): \(rawValueType), Codable, CaseIterable {
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
        
        \(EnumExtensions(typeInformation, rawValueType: rawValueType).render())
        """
    }
}
