//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobufPluginLibrary
import OrderedCollections

class GRPCEnum {
    private static let unrecognizedCaseName = "UNRECOGNIZED"

    let descriptor: EnumDescriptor
    let namer: SwiftProtobufNamer

    let fullname: String
    let relativeName: String

    var unavailable = false // TODO set!
    var containsRootTypeChange = false // TODO use!

    var enumCases: [EnumValueDescriptor] = []
    lazy var enumCasesSorted: [EnumValueDescriptor] = {
        enumCases.sorted(by: \.number)
    }()
    // TODO addedCases!

    var hasUnknownPreservingSemantics: Bool {
        descriptor.file.syntax == .proto3
    }

    init(descriptor: EnumDescriptor, namer: SwiftProtobufNamer) {
        self.descriptor = descriptor
        self.namer = namer

        fullname = namer.fullName(enum: descriptor)
        relativeName = namer.relativeName(enum: descriptor)

        for enumCase in descriptor.values where enumCase.aliasOf == nil {
            enumCases.append(enumCase)
        }

        if enumCases.count > 500 {
            fatalError("We don't support generating very large enums. See https://github.com/apple/swift-protobuf/issues/904.")
        }
    }

    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        // TODO deltaIdentifier
        switch change.updated {
        case .rootType: // TODO model it as removal and addition?
            containsRootTypeChange = true // root type changes are unsupported!
        case .property:
            fatalError("Tried updating enum with message-only change type!")
        case let .case(`case`):
            // TODO we ignore additions right?
            if let caseAddition = `case`.modeledAdditionChange {
                // TODO how to derive the index/number?

                // TODO add a case!
            } else if let caseRemoval = `case`.modeledRemovalChange {
                // TODO deltaIdentifier match right?
                // TODO enumCases.removeAll(where: { $0.name == caseRemoval.id.rawValue })
                // TODO just mark them as removed (aka deprecated them!)
                // TODO prevent encoding of removed cases(?)
            } else if let caseUpdate = `case`.modeledUpdateChange {
                // case statement is used to generate compiler error should enum be updated with new change types
                switch caseUpdate.updated {
                case .rawValue:
                    // same argument as in the `rawValueType` case
                    break
                }
            }
        case .rawValueType:
            // no need to handle this. if we generate a enum it is one without associated values
            // and cases are only encoded via their proto number. Therefore, it isn't relevant
            // if the server interprets the value of the enum case differently.
            break
        }
    }

    @SourceCodeBuilder
    var primaryModelType: String {
        ""
        descriptor.protoSourceComments()
        if unavailable {
            "@available(*, message: \"This enum was removed in the latest version!\")"
        }
        // TODO added cases annotation!
        "public enum \(relativeName): \(namer.swiftProtobufModuleName).Enum, CaseIterable {"
        Indent { // swiftlint:disable:this closure_body_length
            "public typealias RawValue = Int"
            ""

            for enumCase in namer.uniquelyNamedValues(enum: descriptor) {
                enumCase.protoSourceComments()

                let relativeName = namer.relativeName(enumValue: enumCase)
                if let aliasOf = enumCase.aliasOf {
                    "public static let \(relativeName) = \(namer.relativeName(enumValue: aliasOf))"
                } else {
                    "case \(relativeName) // = \(enumCase.number)"
                }
            }
            if hasUnknownPreservingSemantics {
                "case \(Self.unrecognizedCaseName)(Int)"
            }

            // rawValue property
            ""
            "var rawValue: Int {"
            Indent {
                "switch self {"
                for enumCase in enumCasesSorted {
                    "case \(namer.dottedRelativeName(enumValue: enumCase)): return \(enumCase.number)"
                }

                if hasUnknownPreservingSemantics {
                    "case let .\(Self.unrecognizedCaseName)(number): return number"
                }
                "}"
            }
            "}"

            // CaseIterable
            if hasUnknownPreservingSemantics {
                ""
                "public static var allCases: [\(fullname)] = ["
                Indent {
                    Joined(by: ",") { // TODO does Joined work here?
                        for enumCase in enumCasesSorted {
                            "\(namer.dottedRelativeName(enumValue: enumCase))"
                        }
                    }
                }
                "]"
            }


            // default value init
            ""
            "public init() {"
            Indent("self = \(namer.dottedRelativeName(enumValue: descriptor.defaultValue))")
            "}"

            // RawValue init
            ""
            "public init\(hasUnknownPreservingSemantics ? "": "?")(rawValue: Int) {"
            Indent {
                "switch rawValue {"
                for enumCase in enumCasesSorted {
                    "case \(enumCase.number): self = \(namer.dottedRelativeName(enumValue: enumCase))"
                }

                if hasUnknownPreservingSemantics {
                    "default: self = .\(Self.unrecognizedCaseName)(rawValue)"
                } else {
                    "default: return nil"
                }
                "}"
            }
            "}"
        }
        "}"
    }

    @SourceCodeBuilder
    var protobufferRuntimeSupport: String {
        ""
        "extension \(fullname): \(namer.swiftProtobufModuleName)._ProtoNameProviding {"
        Indent {
            "public static let _protobuf_nameMap: \(namer.swiftProtobufModuleName)._NameMap = ["
            for enumCase in enumCasesSorted {
                // TODO use `Joined` operator?
                if enumCase.aliases.isEmpty {
                    "\(enumCase.number): .same(proto: \"\(enumCase.name)\"),"
                } else {
                    let aliasNames = enumCase.aliases
                        .map { "\"\($0.name)\"" }
                        .joined(separator: ", ")
                    "\(enumCase.number): .aliased(proto: \"\(enumCase.name)\", aliases: [\(aliasNames)]),"
                }
            }
            "]"
        }
        "}"
    }
}
