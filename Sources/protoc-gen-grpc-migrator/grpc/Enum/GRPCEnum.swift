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

@dynamicMemberLookup
struct GRPCEnum: SourceCodeRenderable {
    private static let unrecognizedCaseName = "UNRECOGNIZED"

    private let `enum`: SomeGRPCEnum
    var context: ProtoFileContext {
        `enum`.context
    }

    init(_ `enum`: SomeGRPCEnum) {
        self.enum = `enum`
    }

    subscript<T>(dynamicMember member: KeyPath<SomeGRPCEnum, T>) -> T {
        `enum`[keyPath: member]
    }

    func tryTyped<Enum: SomeGRPCEnum>(for type: Enum.Type = Enum.self) -> Enum? {
        `enum` as? Enum
    }

    var renderableContent: String {
        var deprecatedCases: [GRPCEnumCase] = []

        ""
        if let comments = `enum`.sourceCodeComments {
            comments
        }

        if `enum`.unavailable {
            "@available(*, deprecated, message: \"This enum was removed in the latest version!\")"
        } else if `enum`.containsRootTypeChange {
            """
            @available(*, deprecated, message: \"ApodiniMigrator is not able to handle the migration of this enum. \
            Change from enum to object or vice versa is currently not supported.\")
            """
        }

        "\(context.options.visibility) enum \(`enum`.relativeName): \(context.namer.swiftProtobufModuleName).Enum, CaseIterable {"
        Indent { // swiftlint:disable:this closure_body_length
            "\(context.options.visibility) typealias RawValue = Int"
            ""

            for enumCase in `enum`.uniquelyNamedValues {
                if enumCase.unavailable {
                    deprecatedCases.append(enumCase)
                }

                // if new cases are added, the client developer will be made aware of
                // through compiler errors to when it is required to adjust switch statements!

                if let comments = enumCase.sourceCodeComments {
                    comments
                }

                if enumCase.unavailable {
                    "@available(*, deprecated, message: \"This enum case was removed in the latest version!\")"
                }

                if let aliasOf = enumCase.aliasOf {
                    "\(context.options.visibility) static let \(enumCase.relativeName) = \(aliasOf.relativeName)"
                } else {
                    "case \(enumCase.relativeName) // = \(enumCase.number)"
                }
            }
            if context.hasUnknownPreservingSemantics {
                "case \(Self.unrecognizedCaseName)(Int)"
            }

            // rawValue property
            ""
            "\(context.options.visibility) var rawValue: Int {"
            Indent {
                // TODO do we need to handle removed enum cases?
                //  => does Apodini support the \(unrecognizedCaseName) case?
                //   => we could also use default case? or throw in rawValue (ensure client doesn't use rawValue?)

                "switch self {"
                for enumCase in `enum`.enumCasesSorted {
                    "case \(enumCase.dottedRelativeName): return \(enumCase.number)"
                }

                if context.hasUnknownPreservingSemantics {
                    "case let .\(Self.unrecognizedCaseName)(number): return number"
                }
                "}"
            }
            "}"

            // CaseIterable
            if context.hasUnknownPreservingSemantics {
                ""
                "\(context.options.visibility) static var allCases: [\(`enum`.fullName)] = ["
                Indent {
                    Joined(by: ",") { // TODO does Joined work here?
                        for enumCase in `enum`.enumCasesSorted {
                            "\(enumCase.dottedRelativeName)"
                        }
                    }
                }
                "]"
            }


            // default value init
            ""
            "\(context.options.visibility) init() {"
            Indent("self = \(`enum`.defaultValue.dottedRelativeName)")
            "}"

            // RawValue init
            ""
            "\(context.options.visibility) init\(context.hasUnknownPreservingSemantics ? "": "?")(rawValue: Int) {"
            Indent {
                "switch rawValue {"
                for enumCase in `enum`.enumCasesSorted {
                    "case \(enumCase.number): self = \(enumCase.dottedRelativeName)"
                }

                if context.hasUnknownPreservingSemantics {
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
        "extension \(`enum`.fullName): \(context.namer.swiftProtobufModuleName)._ProtoNameProviding {"
        Indent {
            "\(context.options.visibility) static let _protobuf_nameMap: \(context.namer.swiftProtobufModuleName)._NameMap = ["
            for enumCase in `enum`.enumCasesSorted {
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
