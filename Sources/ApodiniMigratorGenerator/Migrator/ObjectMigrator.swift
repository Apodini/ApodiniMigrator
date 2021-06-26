//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation

struct AddedProperty {
    let typeProperty: TypeProperty
    let jsonValueID: Int
}

struct DeletedProperty {
    let id: DeltaIdentifier
    let jsonValueID: Int
    
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
    private var propertyNecessityChanges: [UpdateChange] = []
    private var propertyConvertChanges: [UpdateChange] = []
    
    init(_ typeInformation: TypeInformation, changes: [Change]) {
        self.typeInformation = typeInformation
        self.oldProperties = typeInformation.objectProperties
        self.changes = changes
        kind = .struct
        unsupportedChange = changes.first { $0.type == .unsupported } as? UnsupportedChange
        notPresentInNewVersion = changes.contains(where: { $0.type == .deletion && $0.element.target == ObjectTarget.`self`.rawValue })
        collectPropertyChanges()
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
        
        let addedProperties: [AddedProperty] = addedPropertyChanges.compactMap {
            if case let .element(anyCodable) = $0.added, case let .json(defaultJSONValueID) = $0.defaultValue {
                return .init(typeProperty: anyCodable.typed(TypeProperty.self), jsonValueID: defaultJSONValueID)
            }
            return nil
        }
        
        let allProperties = (typeInformation.objectProperties + addedProperties.map(\.typeProperty)).sorted(by: \.name)
        
        let deletedProperties: [DeletedProperty] = deletedPropertyChanges.compactMap { change in
            if case let .elementID(id) = change.deleted, case let .json(fallbackJSONValueID) = change.fallbackValue {
                return .init(id: id, jsonValueID: fallbackJSONValueID)
            }
            return nil
        }
        
        let objectInitializer = ObjectInitializer(typeInformation.objectProperties, addedProperties: addedProperties)
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
        \(header())
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
    
    private func header() -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(kind.signature) \(typeNameString): Codable {
        \(MARKComment(.codingKeys))
        """
    }
    
    private mutating func collectPropertyChanges() {
        let propertyTargets = [ObjectTarget.property, .necessity].map { $0.rawValue }
        for change in changes where propertyTargets.contains(change.element.target) {
            if let deleteChange = change as? DeleteChange {
                deletedPropertyChanges.append(deleteChange)
            } else if let addChange = change as? AddChange {
                addedPropertyChanges.append(addChange)
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
}
