//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

struct AddedProperty {
    let typeProperty: TypeProperty
    let defaultValueJSON: String
}

struct DeletedProperty {
    let id: DeltaIdentifier
    let fallbackValueJSON: String
    
}


struct ObjectMigrator: SwiftFileTemplate {
    var typeInformation: TypeInformation
    var kind: Kind
    let unsupportedChange: UnsupportedChange?
    let notPresentInNewVersion: Bool
    let oldProperties: [TypeProperty]
    let changes: [Change]
    private var addedPropertyChanges: [AddChange] = []
    private var deletedPropertyChanges: [DeleteChange] = []
    private var renamePropertyChanges: [UpdateChange] = []
    private var propertyOptionalityChanges: [UpdateChange] = []
    private var propertyConvertChanges: [UpdateChange] = []
    
    init(_ typeInformation: TypeInformation, changes: [Change]) {
        self.typeInformation = typeInformation
        self.oldProperties = typeInformation.objectProperties
        self.changes = changes
        unsupportedChange = changes.first { $0.type == .unsupported } as? UnsupportedChange
        notPresentInNewVersion = changes.contains(where: { $0.type == .deletion && $0.element.target == ObjectTarget.`self`.rawValue })
        self.kind = .struct
        collectChanges()
    }
    
    func render() -> String {
        var annotation: Annotation?
        if let unsupportedChange = unsupportedChange {
            annotation = GenericComment(
                comment: "@available(*, unavailable, message: \(unsupportedChange.description.doubleQuoted))"
            )
        } else if notPresentInNewVersion {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \"This model is not used in the new version anymore!\")"
            )
        }
        
        if (oldProperties.isEmpty && addedPropertyChanges.isEmpty) || annotation != nil {
            let objectFileTemplate = ObjectFileTemplate(typeInformation, annotation: annotation)
            return objectFileTemplate.render()
        }
        var addedProperties: [AddedProperty] = []
        for addChange in addedPropertyChanges {
            if case let .element(anyCodable) = addChange.added, case let .json(json) = addChange.defaultValue {
                addedProperties.append(.init(typeProperty: anyCodable.typed(TypeProperty.self), defaultValueJSON: json))
            }
        }
        var allProperties = (typeInformation.objectProperties + addedProperties.map(\.typeProperty)).sorted(by: \.name)
        
        var deletedProperties: [DeletedProperty] = []
        for deleteChange in deletedPropertyChanges {
            if case let .elementID(id) = deleteChange.deleted, case let .json(json) = deleteChange.fallbackValue {
                deletedProperties.append(.init(id: id, fallbackValueJSON: json))
            }
        }
        
        let fileContent =
        """
        \(header())
        \(ObjectCodingKeys(oldProperties, addedProperties: addedProperties.map(\.typeProperty), renameChanges: renamePropertyChanges).render())

        \(MARKComment(.properties))
        \(allProperties.map { $0.propertyLine }.lineBreaked)
        
        \(MARKComment(.initializer))
        \(ObjectInitializer(typeInformation.objectProperties, addedProperties: addedProperties).render())

        \(MARKComment(.encodable))
        \(EncodingMethod(allProperties, deletedIDs: deletedProperties.map(\.id), optionalityChanges: propertyOptionalityChanges, convertChanges: propertyOptionalityChanges).render())

        \(MARKComment(.decodable))
        \(DecoderInitializer(allProperties).render())
        }
        """
        return fileContent
    }
    
    private func header() -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(kind.signature) \(typeNameString): Codable {
        \(MARKComment(.codingKeys))
        """
    }
    
    private mutating func collectChanges() {
        for change in changes where change.element.target == ObjectTarget.property.rawValue {
            if let deleteChange = change as? DeleteChange {
                deletedPropertyChanges.append(deleteChange)
            } else if let addChange = change as? AddChange {
                addedPropertyChanges.append(addChange)
            } else if let updateChange = change as? UpdateChange {
                if updateChange.type == .rename {
                    renamePropertyChanges.append(updateChange)
                } else if updateChange.element.target == ObjectTarget.propertyOptionality.rawValue {
                    propertyOptionalityChanges.append(updateChange)
                } else if updateChange.type == .propertyChange {
                    propertyConvertChanges.append(updateChange)
                }
            }
        }
    }
}
