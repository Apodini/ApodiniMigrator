//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents an `object` file that was not affected by any change
struct DefaultObjectFile: GeneratedFile {
    var fileName: [NameComponent] {
        ["\(typeInformation.typeName.mangledName).swift"] // TODO file name uniqueness
    }

    /// `TypeInformation` to be rendered in this file
    let typeInformation: TypeInformation
    
    /// Kind of the object, either `struct` or `class`
    let kind: Kind
    
    /// Optional annotation that can be rendered in the file declaration
    private let annotation: Annotation?
    
    private var annotationComment: String {
        if let annotation = annotation {
            return annotation.comment + .lineBreak
        }
        return ""
    }
    
    /// Properties of the object
    private let properties: [TypeProperty]
    
    /// CodingKeys enum of the object
    private var codingKeysEnum: ObjectCodingKeys {
        .init(properties)
    }
    
    /// Initializer of the object
    private var objectInitializer: ObjectInitializer {
        .init(properties)
    }
    
    /// Encoding method of the object
    private var encodingMethod: EncodingMethod {
        .init(properties: properties)
    }
    
    /// Decoder initializer of the object
    private var decoderInitializer: DecoderInitializer {
        .init(properties: properties)
    }
    
    /// Initializer
    /// - Parameters:
    ///     - typeInformation: typeInformation to render
    ///     - kind: the kind of the file, if other than .struct or .class is passed, .struct is chosen by default
    ///     - annotation: an annotation on the object, e.g. if the model is not present in the new version anymore
    init(_ typeInformation: TypeInformation, kind: Kind = .struct, annotation: Annotation? = nil) {
        precondition([.struct, .class].contains(kind) && typeInformation.isObject, "Can't initialize an ObjectFile with a non object type information or file other than struct or class")
        self.typeInformation = typeInformation
        self.kind = kind
        self.properties = typeInformation.objectProperties.sorted(by: \.name)
        self.annotation = annotation
    }

    var renderableContent: String {
        FileHeaderComment()

        Import(.foundation)
        ""

        MARKComment(.model)
        "\(annotationComment)\(kind.signature) \(typeInformation.typeName.mangledName): Codable {" // TODO file name uniqueness

        Indent {
            if properties.isEmpty {
                MARKComment(.initializer)
                "public init() {}"
            } else {
                MARKComment(.codingKeys)
                codingKeysEnum
                ""
                MARKComment(.properties)
                for property in properties {
                    property.propertyLine
                }
                ""
                MARKComment(.initializer)
                objectInitializer
                ""
                MARKComment(.encodable)
                encodingMethod
                ""
                MARKComment(.decodable)
                decoderInitializer
            }
        }

        "}"
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered under the list of properties of the object
    var propertyLine: String {
        "public var \(name): \(type.typeString)"
    }
}
