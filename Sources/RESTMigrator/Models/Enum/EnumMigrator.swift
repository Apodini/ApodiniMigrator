//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCompare
import ApodiniMigrator

/// An object that handles the migration of an enum declaration and renders the output accordingly
struct EnumMigrator: GeneratedFile {
    var fileName: [NameComponent] {
        ["\(typeInformation.unsafeFileNaming).swift"]
    }

    /// Type information enum that will be rendered
    private let typeInformation: TypeInformation
    /// RawValue type of the enum, either int or string
    private let rawValueType: TypeInformation


    private var addedCases: [EnumCase] = []
    private var removedCases: [EnumCase] = []
    /// A dictionary holding updates of the raw values of the enum.
    /// Mapping case identifier/name to case rawValue!
    private var rawValueUpdates: [DeltaIdentifier: String] = [:]

    /// A flag that indicates whether enum has been deleted in the new version
    private let notPresentInNewVersion: Bool
    /// An unsupported change related to the enum from the migration guide,
    private var unsupportedChanges: [UnsupportedChange<TypeInformation>] = []

    /// Initializes a new instance out of an `enum` type information and its corresponding changes
    init(_ typeInformation: TypeInformation, changes: [ModelChange]) {
        precondition(!changes.contains(where: { $0.id != typeInformation.deltaIdentifier }), "Found unrelated changes for \(typeInformation)")

        guard typeInformation.isEnum, let rawValueType = typeInformation.sanitizedRawValueType else {
            fatalError("Attempted to initialize EnumMigrator with a non enum TypeInformation \(typeInformation.rootType)")
        }

        self.typeInformation = typeInformation
        self.rawValueType = rawValueType

        notPresentInNewVersion = changes.contains(where: { $0.type == .removal })

        for change in changes.compactMap({ $0.modeledUpdateChange }) {
            // first step is to check for unsupported changes and mark them as such
            if case .rootType = change.updated {
                let unsupportedChange = Change(from: change)
                    .classifyUnsupported(description: """
                                                      ApodiniMigrator is not able to handle the migration of \(change.id). \
                                                      Change from enum to object or vice versa is currently not supported.
                                                      """)
                unsupportedChanges.append(unsupportedChange)
                continue
            } else if case let .rawValueType(_, to) = change.updated {
                let unsupportedChange = Change(from: change)
                    .classifyUnsupported(description: """
                                                      The raw value type of this enum has changed to \(to.nestedTypeString). \
                                                      ApodiniMigrator is not able to migrate this change.
                                                      """)
                unsupportedChanges.append(unsupportedChange)
                continue
            }

            // now we analyze for case changes (additions, removal and updates)
            guard case let .`case`(caseChange) = change.updated else {
                continue
            }

            if let caseAddition = caseChange.modeledAdditionChange {
                self.addedCases.append(caseAddition.added)
            } else if let caseRemoval = caseChange.modeledRemovalChange {
                if let deletedCase = typeInformation.enumCases.first(where: { $0.deltaIdentifier == caseRemoval.id }) {
                    removedCases.append(deletedCase)
                }
            } else if let caseUpdate = caseChange.modeledUpdateChange,
                      case let .rawValue(from, to) = caseUpdate.updated {
                self.rawValueUpdates[caseUpdate.id] = to
            }
        }
    }

    /// Returns the corresponding raw value of the case, considering potential updates
    private func rawValue(for case: EnumCase) -> String {
        if let updated = rawValueUpdates[`case`.deltaIdentifier] {
            return " = \(updated.doubleQuoted)"
        }
        return ""
    }

    var renderableContent: String {
        var annotation: Annotation? = nil

        if !unsupportedChanges.isEmpty {
            annotation = GenericComment(
                comment: "@available(*, deprecated, message: \"\(unsupportedChanges.map { $0.description }.joined(separator: "; "))\")"
            )
        } else if notPresentInNewVersion {
            annotation = GenericComment(
                comment: "@available(*, message: \("This enum is not used in the new version anymore!".doubleQuoted))"
            )
        }


        if let annotation = annotation {
            DefaultEnumFile(typeInformation, annotation: annotation)
        } else {
            let allCases = (typeInformation.enumCases + addedCases).sorted(by: \.name)

            var addedCasesAnnotation = ""

            if !addedCases.isEmpty {
                addedCasesAnnotation = "@available(*, message: \("This enum has been migrated with new cases. The client developer should ensure to adjust potential switch blocks of this enum".doubleQuoted))" + .lineBreak
            }

            FileHeaderComment()

            Import(.foundation)
            ""

            MARKComment(.model)
            "\(addedCasesAnnotation)\(Kind.enum.signature) \(typeInformation.unsafeFileNaming): \(rawValueType.nestedTypeString), Codable, CaseIterable {"
            Indent {
                for enumCase in allCases {
                    precondition(enumCase.name == enumCase.rawValue, "Assumption about the TypeInformation framework changed!")
                    "case \(enumCase.name)\(rawValue(for: enumCase))"
                }
                ""

                MARKComment(.deprecated)
                EnumDeprecatedCases(deprecated: self.removedCases)
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
