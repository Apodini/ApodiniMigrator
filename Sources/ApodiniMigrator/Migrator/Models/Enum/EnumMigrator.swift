//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCompare
import MigratorAPI

/// An object that handles the migration of an enum declaration and renders the output accordingly
struct EnumMigrator: GeneratedFile {
    var fileName: [NameComponent] {  // TODO duplicates in SwiftFile!
        ["\(typeInformation.typeName.name).swift"]
    }

    /// Type information enum that will be rendered
    let typeInformation: TypeInformation
    /// Kind of the file, always `.enum`
    let kind: Kind = .enum
    /// RawValue type of the enum, either int or string
    private let rawValueType: TypeInformation
    /// An unsupported change related to the enum from the migration guide,
    private let unsupportedChange: UnsupportedChange?
    /// A flag that indicates whether enum has been deleted in the new version
    private let notPresentInNewVersion: Bool
    /// All changes related to the `enum`
    private let changes: [Change]
    /// A dictionary holding updates of the raw values of the enum
    private var rawValueUpdates: [EnumCase: EnumCase] = [:]
    
    /// Initializes a new instance out of an `enum` type information and its correspoinding changes
    init(_ typeInformation: TypeInformation, changes: [Change]) {
        guard typeInformation.isEnum, let rawValueType = typeInformation.sanitizedRawValueType else {
            fatalError("Attempted to initialize EnumMigrator with a non enum TypeInformation \(typeInformation.rootType)")
        }

        self.typeInformation = typeInformation
        self.rawValueType = rawValueType
        self.changes = changes

        unsupportedChange = changes.first { $0.type == .unsupported } as? UnsupportedChange
        notPresentInNewVersion = changes.contains(where: { $0.type == .deletion && $0.element.target == EnumTarget.`self`.rawValue })
        setRawValueUpdates()
    }
    
    /// Returns the corresponding raw value of the case, considering potential updates
    private func rawValue(for case: EnumCase) -> String {
        if let updated = rawValueUpdates[`case`] {
            return " = \(updated.name.doubleQuoted)"
        }
        return ""
    }

    /// Filters changes and returns the added cases of the enum if any
    private func addedCases() -> [EnumCase] {
        var retValue: [EnumCase] = []
        
        for change in changes where change.element.target == EnumTarget.case.rawValue {
            if let addChange = change as? AddChange, case let .element(anyCodable) = addChange.added {
                retValue.append(anyCodable.typed(EnumCase.self))
            }
        }
        return retValue
    }
    
    /// Filters changes and returns the deleted cases of the enum if any
    private func deletedCases() -> [EnumCase] {
        var retValue: [EnumCase] = []
        
        for change in changes where change.element.target == EnumTarget.case.rawValue {
            if
                let deleteChange = change as? DeleteChange,
                case let .elementID(id) = deleteChange.deleted,
                let deletedCase = typeInformation.enumCases.firstMatch(on: \.deltaIdentifier, with: id)
            {
                retValue.append(deletedCase)
            }
        }
        return retValue
    }
    
    /// Filters changes and sets the corresponding raw value updates in `rawValueUpdates` dictionary
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

    var fileContent: String {
        var annotation: Annotation? = nil

        if let unsupportedChange = unsupportedChange {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \(unsupportedChange.description.doubleQuoted))"
            )
        } else if notPresentInNewVersion {
            annotation = GenericComment(
                comment: "@available(*, message: \("This enum is not used in the new version anymore!".doubleQuoted))"
            )
        }


        if let annotation = annotation {
            DefaultEnumFile(typeInformation, annotation: annotation)
        } else  {
            let addedCases = self.addedCases()
            let allCases = (typeInformation.enumCases + addedCases).sorted(by: \.name)

            var addedCasesAnnotation = ""

            if !addedCases.isEmpty {
                addedCasesAnnotation = "@available(*, message: \("This enum has been migrated with new cases. The client developer should ensure to adjust potential switch blocks of this enum".doubleQuoted))" + .lineBreak
            }

            FileHeaderComment()

            Import(.foundation)
            ""

            MARKComment(.model)
            "\(addedCasesAnnotation)\(kind.signature) \(typeInformation.typeName.name): \(rawValueType.nestedTypeString), Codable, CaseIterable {"
            Indent {
                for enumCase in allCases {
                    "case \(enumCase.name)\(rawValue(for: enumCase))"
                }
                ""

                MARKComment(.deprecated)
                EnumDeprecatedCases(deprecated: deletedCases())
                ""
                MARKComment(.encodable)
                EnumEncodingMethod()
                ""
                MARKComment(.decodable)
                EnumDecoderInitializer(allCases)
                ""
                MARKComment(.utils)
                EnumEncodeValueMethod()
            }
            "}"

            ""
            EnumExtensions(typeInformation, rawValueType: rawValueType)
        }
    }
}
