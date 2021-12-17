//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// A util struct that holds an added property and its corresponding default value as provided by the migration guide
struct AddedProperty {
    /// Property
    let typeProperty: TypeProperty
    /// Default value
    let defaultValue: ChangeValue
}

/// A util struct that holds the id of a deleted property and its corresponding fallback value as provided by the migration guide
struct DeletedProperty { // TODO remove both!
    /// Id of the property
    let id: DeltaIdentifier
    /// Fallback value
    let fallbackValue: ChangeValue
}

/// An object that handles the migration of an object in the client library
struct ObjectMigrator: GeneratedFile {
    var fileName: [NameComponent] {
        ["\(typeInformation.typeName.mangledName).swift"] // TODO file name uniqueness!
    }

    /// Type information of the object that will be migrated
    var typeInformation: TypeInformation
    /// Kind of the file, either object or struct
    var kind: Kind

    /// An unsupported change related to this object if any contained in the migration guide
    private var unsupportedChanges: [NewUnsupportedChange<ModelChangeDeclaration>] = []
    /// A flag that indicates whether the object is present in the new version or not
    private let notPresentInNewVersion: Bool

    /// All old properties of the object
    private let basedProperties: [TypeProperty]

    /// Holds all renamed property changes. It maps the old property identifier to the new identifier.
    private var renamedProperties: [PropertyChange.IdentifierChange] = []
    /// All properties that have been added in the new version
    private var addedProperties: [PropertyChange.AdditionChange] = []
    /// All properties that have been deleted in the new version
    private var removedProperties: [PropertyChange.RemovalChange] = []
    /// All properties that have been updated in the new version (necessity or type).
    private var updatedProperties: [PropertyChange.UpdateChange] = []
    
    /// Initializes a new instance out of an object type information, kind of the file and the changes related to the object
    init(_ typeInformation: TypeInformation, kind: Kind = .struct, changes: [ModelChange]) {
        precondition([.struct, .class].contains(kind) && typeInformation.isObject, "Can't initialize an ObjectMigrator with a non object type information or file other than struct or class")
        precondition(!changes.contains(where: { $0.id != typeInformation.deltaIdentifier }), "Found unrelated changes for \(typeInformation)")

        self.typeInformation = typeInformation
        self.kind = kind
        self.basedProperties = typeInformation.objectProperties

        self.notPresentInNewVersion = changes.contains(where: { $0.type == .removal })

        for change in changes.compactMap({ $0.modeledUpdateChange }) {
            // first step is to check for unsupported changes and mark them as such
            if case .rootType = change.updated {
                let unsupportedChange = ChangeEnum(from: change)
                    .classifyUnsupported(description: """
                                                      ApodiniMigrator is not able to handle the migration of \(change.id). \
                                                      Change from enum to object or vice versa is currently not supported.
                                                      """)
                unsupportedChanges.append(unsupportedChange)
                continue
            }

            // now we analyze for property changes (additions, removal and updates)
            guard case let .property(propertyChange) = change.updated else {
                continue
            }

            if let idChange = propertyChange.modeledIdentifierChange {
                self.renamedProperties.append(idChange)
            } else if let propertyAddition = propertyChange.modeledAdditionChange {
                self.addedProperties.append(propertyAddition)
            } else if let propertyRemoval = propertyChange.modeledRemovalChange {
                self.removedProperties.append(propertyRemoval)
            } else if let propertyUpdate = propertyChange.modeledUpdateChange {
                self.updatedProperties.append(propertyUpdate)
            }
        }
    }

    var renderableContent: String {
        var annotation: Annotation? = nil
        if !unsupportedChanges.isEmpty {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \(unsupportedChanges.map { $0.description }.joined(separator: "; ")))"
            )
        } else if notPresentInNewVersion {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \"This model is not used in the new version anymore!\")"
            )
        }


        if (basedProperties.isEmpty && addedProperties.isEmpty) || annotation != nil {
            DefaultObjectFile(typeInformation, annotation: annotation)
        } else {
            let allProperties = (basedProperties + addedProperties.map(\.added))
                .sorted(by: \.name)

            let objectInitializer = ObjectInitializer(basedProperties, addedProperties: addedProperties)

            let encodingMethod = EncodingMethod(
                properties: allProperties.filter { property in
                    !removedProperties.contains(where: {  $0.id ==  property.deltaIdentifier })
                },
                changes: updatedProperties
            )

            let decoderInitializer = DecoderInitializer(
                properties: allProperties,
                removed: removedProperties,
                changes: updatedProperties
            )


            FileHeaderComment()

            Import(.foundation)
            ""

            MARKComment(.model)
            // TODO type name uniqueness
            "\(annotation?.comment ?? "")\(kind.signature) \(typeInformation.typeName.mangledName): Codable {"
            Indent {
                MARKComment(.codingKeys)
                ObjectCodingKeys(allProperties, renameChanges: renamedProperties)
                ""

                MARKComment(.properties)
                for property in allProperties {
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
            "}"
        }
    }
}
