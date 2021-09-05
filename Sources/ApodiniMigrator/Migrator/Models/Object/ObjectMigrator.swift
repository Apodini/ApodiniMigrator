//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A util struct that holds an added property and its corresponding default value as provided by the migration guide
struct AddedProperty {
    /// Property
    let typeProperty: TypeProperty
    /// Default value
    let defaultValue: ChangeValue
}

/// A util struct that holds the id of a deleted property and its corresponding fallback value as provided by the migration guide
struct DeletedProperty {
    /// Id of the property
    let id: DeltaIdentifier
    /// Fallback value
    let fallbackValue: ChangeValue
}

/// An object that handles the migration of an object in the client library
struct ObjectMigrator: ObjectSwiftFile {
    /// Type information of the object that will be migrated
    var typeInformation: TypeInformation
    /// Kind of the file, either object or struct
    var kind: Kind
    /// An unsupported change related to this object if any contained in the migration guide
    private let unsupportedChange: UnsupportedChange?
    /// A flag that indicates whether the object is present in the new version or not
    private let notPresentInNewVersion: Bool
    /// All old properties of the object
    private let oldProperties: [TypeProperty]
    /// Changes related to the object
    private let changes: [Change]
    /// All properties that have been added in the new version
    private var addedProperties: [AddedProperty] = []
    /// All properties that have been deleted in the new version
    private var deletedProperties: [DeletedProperty] = []
    /// All renaming changes of properties
    private var renamePropertyChanges: [UpdateChange] = []
    /// All necessity changes of properties
    private var propertyNecessityChanges: [UpdateChange] = []
    /// All convert changes of the properties
    private var propertyConvertChanges: [UpdateChange] = []
    
    /// Initializes a new instance out of an object type information, kind of the file and the changes related to the object
    init(_ typeInformation: TypeInformation, kind: Kind = .struct, changes: [Change]) {
        precondition([.struct, .class].contains(kind) && typeInformation.isObject, "Can't initialize an ObjectMigrator with a non object type information or file other than struct or class")
        self.typeInformation = typeInformation
        self.oldProperties = typeInformation.objectProperties
        self.changes = changes
        self.kind = kind
        unsupportedChange = changes.first { $0.type == .unsupported } as? UnsupportedChange
        notPresentInNewVersion = changes.contains(where: { $0.type == .deletion && $0.element.target == ObjectTarget.`self`.rawValue })
        collectPropertyChanges()
    }
    
    /// Collects and stores property changes in the corresponding variables of the file
    private mutating func collectPropertyChanges() {
        let propertyTargets = [ObjectTarget.property, .necessity].map { $0.rawValue }
        for change in changes where propertyTargets.contains(change.element.target) {
            if let deleteChange = change as? DeleteChange, case let .elementID(id) = deleteChange.deleted {
                deletedProperties.append(.init(id: id, fallbackValue: deleteChange.fallbackValue))
            } else if let addChange = change as? AddChange, case let .element(anyCodable) = addChange.added {
                addedProperties.append(.init(typeProperty: anyCodable.typed(TypeProperty.self), defaultValue: addChange.defaultValue))
            } else if let updateChange = change as? UpdateChange {
                if updateChange.type == .rename {
                    renamePropertyChanges.append(updateChange)
                } else if updateChange.element.target == ObjectTarget.necessity.rawValue {
                    propertyNecessityChanges.append(updateChange)
                } else if updateChange.type == .propertyChange {
                    propertyConvertChanges.append(updateChange)
                }
            }
        }
    }
    
    /// Renders the migrated result of the object
    func render() -> String {
        var annotation: Annotation?
        if let unsupportedChange = unsupportedChange {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \(unsupportedChange.description.doubleQuoted))"
            )
        } else if notPresentInNewVersion {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \"This model is not used in the new version anymore!\")"
            )
        }
        
        if (oldProperties.isEmpty && addedProperties.isEmpty) || annotation != nil {
            let objectFileTemplate = DefaultObjectFile(typeInformation, annotation: annotation)
            return objectFileTemplate.render()
        }
        
        let allProperties = (oldProperties + addedProperties.map(\.typeProperty)).sorted(by: \.name)
        
        let objectInitializer = ObjectInitializer(oldProperties, addedProperties: addedProperties)
        let encodingMethod = EncodingMethod(
            allProperties.filter { !deletedProperties.map(\.id).contains($0.deltaIdentifier) },
            necessityChanges: propertyNecessityChanges,
            convertChanges: propertyConvertChanges
        )
        
        let decoderInitializer = DecoderInitializer(
            allProperties,
            deleted: deletedProperties,
            necessityChanges: propertyNecessityChanges,
            convertChanges: propertyConvertChanges
        )
        
        let fileContent =
        """
        \(fileHeader(annotation: annotation?.comment ?? ""))
        \(MARKComment(.codingKeys))
        \(ObjectCodingKeys(allProperties, renameChanges: renamePropertyChanges).render())

        \(MARKComment(.properties))
        \(allProperties.map { $0.propertyLine }.lineBreaked)
        
        \(MARKComment(.initializer))
        \(objectInitializer.render())

        \(MARKComment(.encodable))
        \(encodingMethod.render())

        \(MARKComment(.decodable))
        \(decoderInitializer.render())
        }
        """
        return fileContent
    }
}
