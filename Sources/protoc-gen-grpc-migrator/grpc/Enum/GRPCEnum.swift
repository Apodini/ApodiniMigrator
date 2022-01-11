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
        ""
        if let comments = `enum`.sourceCodeComments {
            comments
        }

        if `enum`.unavailable {
            "@available(*, message: \"This enum was removed in the latest version!\")"
        }
        // TODO added cases annotation!
        "public enum \(`enum`.relativeName): \(context.namer.swiftProtobufModuleName).Enum, CaseIterable {"
        Indent { // swiftlint:disable:this closure_body_length
            "public typealias RawValue = Int"
            ""

            for enumCase in `enum`.uniquelyNamedValues {
                if let comments = enumCase.sourceCodeComments {
                    comments
                }

                if let aliasOf = enumCase.aliasOf {
                    "public static let \(enumCase.relativeName) = \(aliasOf.relativeName)"
                } else {
                    "case \(enumCase.relativeName) // = \(enumCase.number)"
                }
            }
            if context.hasUnknownPreservingSemantics {
                "case \(Self.unrecognizedCaseName)(Int)"
            }

            // rawValue property
            ""
            "var rawValue: Int {"
            Indent {
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
                "public static var allCases: [\(`enum`.fullName)] = ["
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
            "public init() {"
            Indent("self = \(`enum`.defaultValue.dottedRelativeName)")
            "}"

            // RawValue init
            ""
            "public init\(context.hasUnknownPreservingSemantics ? "": "?")(rawValue: Int) {"
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
            "public static let _protobuf_nameMap: \(context.namer.swiftProtobufModuleName)._NameMap = ["
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
