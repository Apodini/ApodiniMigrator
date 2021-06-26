//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.06.21.
//

import Foundation
import ApodiniMigratorCompare

struct EnumMigrator: SwiftFileTemplate {
    var typeInformation: TypeInformation
    
    var kind: Kind
    let unsupportedChange: UnsupportedChange?
    let notPresentInNewVersion: Bool
    let changes: [Change]
    
    var rawValueUpdates: [EnumCase: EnumCase] = [:]
    
    init(`enum`: TypeInformation, changes: [Change]) {
        typeInformation = `enum`
        kind = .enum
        self.changes = changes
        unsupportedChange = changes.first { $0.type == .unsupported } as? UnsupportedChange
        notPresentInNewVersion = changes.contains(where: { $0.type == .deletion && $0.element.target == EnumTarget.`self`.rawValue })
        setRawValueUpdates()
    }
    
    
    func render() -> String {
        var annotation: Annotation?
        
        if let unsupportedChange = unsupportedChange {
            annotation = GenericComment(
                comment: "@available(*, unavailable, message: \(unsupportedChange.description.doubleQuoted))"
            )
        } else if notPresentInNewVersion {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \("This enum is not used in the new version anymore!".doubleQuoted))"
            )
        }
        
        if let annotation = annotation {
            let enumFileTemplate = EnumFileTemplate(typeInformation, annotation: annotation)
            return enumFileTemplate.render()
        }
        
        let addedCases = self.addedCases()
        let allCases = typeInformation.enumCases + addedCases
        
        var addedCasesAnnotation = ""
        
        if !addedCases.isEmpty {
            addedCasesAnnotation = "@available(*, introduced, message: \("This enum has been migrated with new cases. The client developer should ensure to adjust potential switch blocks of this enum".doubleQuoted)"
        }
        
        
        let fileContent =
        """
        \(fileComment)

        \(Import(.foundation).render())

        \(MARKComment(.model))
        \(addedCasesAnnotation)\(kind.signature) \(typeNameString): String, Codable, CaseIterable {
        \(allCases.map { "case \($0.name)\(rawValue(for: $0))" }.lineBreaked)

        \(MARKComment(.deprecated))
        \(EnumDeprecatedCases(deprecated: deletedCases()).render())

        \(MARKComment(.encodable))
        \(EnumEncodingMethod().render())

        \(MARKComment(.decodable))
        \(EnumDecoderInitializer(allCases).render())

        \(MARKComment(.utils))
        \(EnumEncodeValueMethod().render())
        }
        """
        
        return fileContent
    }
    
    private func rawValue(for oldCase: EnumCase) -> String {
        if let updated = rawValueUpdates[oldCase] {
            return " = \(updated.name.doubleQuoted)"
        }
        return ""
    }

    private func addedCases() -> [EnumCase] {
        var retValue: [EnumCase] = []
        
        for change in changes where change.element.target == EnumTarget.case.rawValue {
            if let addChange = change as? AddChange, case let .element(enumCase) = addChange.added {
                retValue.append(enumCase.typed(EnumCase.self))
            }
        }
        return retValue
    }
    
    private func deletedCases() -> [EnumCase] {
        var retValue: [EnumCase] = []
        
        for change in changes where change.element.target == EnumTarget.case.rawValue {
            if let deleteChange = change as? DeleteChange, case let .elementID(id) = deleteChange.deleted, let deletedCase = typeInformation.enumCases.firstMatch(on: \.deltaIdentifier, with: id) {
                retValue.append(deletedCase)
            }
        }
        return retValue
    }
    
    private mutating func setRawValueUpdates() {
        for change in changes where change.element.target == EnumTarget.caseRawValue.rawValue {
            if
                let renameChange = change as? UpdateChange,
                case let .element(oldCase) = renameChange.from,
                case let .element(newCase) = renameChange.to {
                rawValueUpdates[oldCase.typed(EnumCase.self)] = newCase.typed(EnumCase.self)
            }
        }
    }
}
