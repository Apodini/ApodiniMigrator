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

class GRPCMessage {
    let descriptor: Descriptor
    let namer: SwiftProtobufNamer

    // TODO contains message or enums again!

    var relativeName: String
    var fullName: String

    var fields: [GRPCMessageField] = []

    init(descriptor: Descriptor, namer: SwiftProtobufNamer) {
        self.descriptor = descriptor
        self.namer = namer

        precondition(descriptor.extensionRanges.isEmpty, "proto extensions are unsupported by the migrator")

        self.relativeName = namer.relativeName(message: descriptor)
        self.fullName = namer.relativeName(message: descriptor)

        // TODO isExtensible

        for field in descriptor.fields {
            fields.append(GRPCMessageField(descriptor: field, namer: namer))
        }

        // TODO nested enums
        // TODO nested messages

        // TODO `storage` stuff?
    }

    @SourceCodeBuilder
    var primaryStruct: String {
        // TODO ExtensibleMessage
        ""
        // TODO visibility
        "public struct \(relativeName) {"
        Indent {
            for field in fields {
                field.propertyInterface
            }
            // TODO fields

            // TODO unknownFilds

            // TODO oneOfs

            // TODO nested enums

            // TODO nested messages

            // TODO extension support; storageClass thingy!
        }
        "}"
    }

    @SourceCodeBuilder
    var runtimeSupport: String {
        "extension \(fullName): \(namer.swiftProtobufModuleName).Message, \(namer.swiftProtobufModuleName)._MessageImplementationBase, \(namer.swiftProtobufModuleName)._ProtoNameProviding {"
        Indent {
            "static let protoMessageName: String = \"\(descriptor.name)\"" // TODO respect parent descriptor file + file package name!

            if fields.isEmpty {
                "public static let _protobuf_nameMap = \(namer.swiftProtobufModuleName)._NameMap()"
            } else {
                "public static let _protobuf_nameMap: \(namer.swiftProtobufModuleName)._NameMap = ["
                Indent {
                    Joined(by: ",") { // TODO does the joined work here?
                        for field in fields {
                            "\(field.number): \(field.fieldMapNames)"
                        }
                    }
                }
                "]"
            }
            // TODO heap storage stuff?
            // TODO isInitialized?

            decodeMessageMethod
            ""
            traverseMessageMethod
        }
        "}"
        ""
        "extension \(fullName): Codable {}" // TODO unknown fields must conform to codable?
    }

    @SourceCodeBuilder
    private var decodeMessageMethod: String {
        "public mutating func decodeMessage<D: \(namer.swiftProtobufModuleName).Decoder>(decoder: inout D) throws {"
        Indent {
            // TODO uniqueStorage?

            // TODO generateWithLifetimeExtension if using storage?

            "while let \(fields.isEmpty ? "_" : "fieldNumber") = try decoder.nextFieldNumber() {"
            Indent {
                // TODO handle Extensible for empty fields and for non empty fields
                // TODO print https://github.com/apple/swift-protobuf/issues/1034
                "switch fieldNumber {"
                Indent {
                    // TODO sort once and not for every access
                    for field in fields.sorted(by: \.number) {
                        field.fieldDecodeCase
                    }
                }
                "}"
            }
            "}"
        }
        "}"
    }

    @SourceCodeBuilder
    private var traverseMessageMethod: String {
        "public traverse<V: \(namer.swiftProtobufModuleName).Visitor>(visitor: inout V) throws {"
        Indent {
            // TODO "generateWithLifetimeExtension"

            // TODO we don't support storage, extensions nor useMessageSetWireFormat, nor oneOf (we don't support enums with associated values!)
            let visitExtensionsName =
                descriptor.useMessageSetWireFormat ? "visitExtensionFieldsAsMessageSet" : "visitExtensionFields"

            if fields.contains { $0.generateTraverseUsesLocals } {
                // TODO  "// The use of inline closures is to circumvent an issue where the compiler\n",
                //          "// allocates stack space for every if/case branch local when no optimizations\n",
                //          "// are enabled. https://github.com/apple/swift-protobuf/issues/1034 and\n",
                //          "// https://github.com/apple/swift-protobuf/issues/1182\n")
            }

            // TODO var ranges = descriptor.normalizedExtensionRanges.makeIterator() (no need to handle extensions?)
            for field in fields.sorted(by: \.number) {
                field.traverseExpression
            }
            ""
            "try unknownFields.traverse(visitor: %visitor)"
        }
        "}"
    }

    // TODO message equality method
}
