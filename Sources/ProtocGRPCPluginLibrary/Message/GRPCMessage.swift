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

@dynamicMemberLookup
class GRPCMessage: SourceCodeRenderable, ModelContaining {
    private let message: SomeGRPCMessage
    /// This property points to the parent grpc full message name if this message is a nested type.
    /// We need this to properly build the protoMessageName.
    private let parentFullName: String?

    var context: ProtoFileContext {
        message.context
    }

    var migration: MigrationContext {
        message.migration
    }

    var fullName: String {
        message.fullName
    }

    var nestedEnums: OrderedDictionary<String, GRPCEnum> {
        get {
            message.nestedEnums
        }
        set {
            message.nestedEnums = newValue
        }
    }
    var nestedMessages: OrderedDictionary<String, GRPCMessage> {
        get {
            message.nestedMessages
        }
        set {
            message.nestedMessages = newValue
        }
    }

    init(_ message: SomeGRPCMessage, parentFullName: String?) {
        self.message = message
        self.parentFullName = parentFullName
    }

    subscript<T>(dynamicMember member: KeyPath<SomeGRPCMessage, T>) -> T {
        message[keyPath: member]
    }

    func tryTyped<Message: SomeGRPCMessage>(for type: Message.Type = Message.self) -> Message? {
        message as? Message
    }

    var renderableContent: String {
        ""
        if var comments = message.sourceCodeComments, !comments.isEmpty {
            _ = comments.removeLast() // removing last trailing "\n"
            comments
        }
        if message.unavailable {
            "@available(*, message: \"This message was removed in the latest version!\")"
        } else if message.containsRootTypeChange {
            """
            @available(*, deprecated, message: \"ApodiniMigrator is not able to handle the migration of this message. \
            Change from enum to struct or vice versa is currently not supported.\")
            """
        }

        "\(context.options.visibility) struct \(message.relativeName) {"
        Indent {
            for field in message.fields {
                field.propertyInterface
            }

            ""
            "\(context.options.visibility) var unknownFields = \(context.namer.swiftProtobufModuleName).UnknownStorage()"

            ""
            "\(context.options.visibility) init() {}"

            for `enum` in message.nestedEnums.values {
                `enum`
            }

            for message in message.nestedMessages.values {
                message
            }
        }
        "}"
    }

    @SourceCodeBuilder
    var protobufferRuntimeSupport: String {
        let moduleName = context.namer.swiftProtobufModuleName

        ""
        MARKComment("RuntimeSupport")
        "extension \(message.fullName): \(moduleName).Message, \(moduleName)._MessageImplementationBase, \(moduleName)._ProtoNameProviding {"
        Indent {
            if let parentFullName = self.parentFullName {
                "\(context.options.visibility) static let protoMessageName: String = \(parentFullName).protoMessageName + \".\(message.name)\""
            } else if !migration.rhsExporterConfiguration.packageName.isEmpty {
                "\(context.options.visibility) static let protoMessageName: String = _protobuf_package + \".\(message.name)\""
            } else {
                "\(context.options.visibility) static let protoMessageName: String = \"\(message.name)\""
            }

            EmptyLine()
            if message.fields.isEmpty {
                "\(context.options.visibility) static let _protobuf_nameMap = \(moduleName)._NameMap()"
            } else {
                "\(context.options.visibility) static let _protobuf_nameMap: \(moduleName)._NameMap = ["
                Indent {
                    Joined(by: ",") {
                        for field in message.fields {
                            "\(field.number): \(field.fieldMapNames)"
                        }
                    }
                }
                "]"
            }


            // we don't generate `isInitialized` as we don't support proto2 or extensions
            EmptyLine()
            decodeMessageMethod

            EmptyLine()
            traverseMessageMethod
        }
        "}"

        MessageCodableSupport(message: self)

        for `enum` in message.nestedMessages.values {
            `enum`.protobufferRuntimeSupport
        }

        for message in message.nestedMessages.values {
            message.protobufferRuntimeSupport
        }
    }

    @SourceCodeBuilder
    private var decodeMessageMethod: String {
        "\(context.options.visibility) mutating func decodeMessage<D: \(context.namer.swiftProtobufModuleName).Decoder>(decoder: inout D) throws {"
        Indent {
            // we record which fields were decoded. We use this information when generating our necessity migrations!
            "var decodedFieldNumbers: Set<Int> = []"

            "while let \(message.fields.isEmpty ? "_" : "fieldNumber") = try decoder.nextFieldNumber() {"
            Indent {
                "decodedFieldNumbers.insert(fieldNumber)"
                "switch fieldNumber {"
                for field in message.sortedFields where !field.unavailable { // unavailable fields are handled below
                    field.fieldDecodeCase
                }
                "default: break"
                "}"
            }
            "}"

            for field in message.sortedFields {
                // this handles migration to assign default values (e.g. when field was removed or necessity was migrated)
                field.fieldDecodeCaseStatements
            }
        }
        "}"
    }

    @SourceCodeBuilder
    private var traverseMessageMethod: String {
        "\(context.options.visibility) func traverse<V: \(context.namer.swiftProtobufModuleName).Visitor>(visitor: inout V) throws {"
        Indent {
            for field in message.sortedFields where !field.unavailable { // just send non-removed fields!
                field.traverseExpression
            }
            ""
            "try unknownFields.traverse(visitor: &visitor)"
        }
        "}"
    }

    struct MessageCodableSupport: SourceCodeRenderable {
        let message: GRPCMessage

        var renderableContent: String {
            ""
            MARKComment("Codable")
            "extension \(message.fullName): Codable {"
            Indent {
                CodingKeys(message: message)

                EncodeMethod(message: message)

                DecodeInit(message: message)
            }
            "}"
        }

        private struct CodingKeys: SourceCodeRenderable {
            let message: GRPCMessage

            var renderableContent: String {
                "private enum CodingKeys: String, CodingKey {"
                Indent {
                    for field in message.fields {
                        if let updatedName = field.updatedName {
                            "case \(field.name) = \"\(updatedName)\""
                        } else {
                            "case \(field.name)"
                        }
                    }

                    // we deliberately skip encoding and decoding of `unknownStorage`!
                    // its required by the `Message` protocol, but we can't initialize it from the "outside"
                }
                "}"
            }
        }

        struct EncodeMethod: SourceCodeRenderable {
            let message: GRPCMessage

            var renderableContent: String {
                ""
                "\(message.context.options.visibility) func encode(to encoder: Encoder) throws {"
                Indent {
                    "var container = encoder.container(keyedBy: CodingKeys.self)"
                    ""

                    for field in message.fields {
                        field.codableEncodeMethodLine
                    }
                }
                "}"
            }
        }

        struct DecodeInit: SourceCodeRenderable {
            let message: GRPCMessage

            var renderableContent: String {
                ""
                "\(message.context.options.visibility) init(from decoder: Swift.Decoder) throws {"
                Indent {
                    "let container = try decoder.container(keyedBy: CodingKeys.self)"
                    ""

                    for field in message.fields {
                        field.codableDecodeInit
                    }
                }
                "}"
            }
        }
    }
}
