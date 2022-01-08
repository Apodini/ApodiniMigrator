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

    var enumCases: [EnumValueDescriptor] = []
    lazy var enumCasesSorted: [EnumValueDescriptor] = {
        enumCases.sorted(by: \.number)
    }()

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

    @SourceCodeBuilder
    var primaryModelType: String {
        "// GENERATION OF ENUM \(descriptor.name) UNSUPPORTED"
        ""
        descriptor.protoSourceComments()
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
                for enuMCase in enumCasesSorted {
                    "case \(enuMCase.number): self = \(namer.dottedRelativeName(enumValue: enuMCase))"
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
