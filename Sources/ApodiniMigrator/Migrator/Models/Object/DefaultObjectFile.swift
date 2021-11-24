//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MigratorAPI

/// Represents an `object` file that was not affected by any change
struct DefaultObjectFile: ObjectSwiftFile, LegacyGeneratedFile {
    var fileName: [NameComponent] {  // TODO duplicates in SwiftFile!
        ["\(typeInformation.typeName.name).swift"]
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
        .init(properties)
    }
    
    /// Decoder initializer of the object
    private var decoderInitializer: DecoderInitializer {
        .init(properties)
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

    func render(with context: MigrationContext) -> String {
        if properties.isEmpty {
            let content =
            """
            \(fileHeader(annotation: annotationComment))
            \(MARKComment(.initializer))
            public init() {}
            }
            """
            return content
        } else {
            let content =
                """
                \(fileHeader(annotation: annotationComment))
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
