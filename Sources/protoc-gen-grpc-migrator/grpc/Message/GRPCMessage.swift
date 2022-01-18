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
struct GRPCMessage: SourceCodeRenderable, ModelContaining {
    private let message: SomeGRPCMessage
    var context: ProtoFileContext {
        message.context
    }

    var nestedEnums: OrderedDictionary<String, GRPCEnum> {
        get {
            guard let message = tryTyped(for: ProtoGRPCMessage.self) else {
                fatalError("Tried to access enums of a non ProtoGRPCMessage type.")
            }
            return message.nestedEnums
        }
        set {
            guard let message = tryTyped(for: ProtoGRPCMessage.self) else {
                fatalError("Tried to access enums of a non ProtoGRPCMessage type.")
            }
            message.nestedEnums = newValue
        }
    }
    var nestedMessages: OrderedDictionary<String, GRPCMessage> {
        get {
            guard let message = tryTyped(for: ProtoGRPCMessage.self) else {
                fatalError("Tried to access enums of a non ProtoGRPCMessage type.")
            }
            return message.nestedMessages
        }
        set {
            guard let message = tryTyped(for: ProtoGRPCMessage.self) else {
                fatalError("Tried to access enums of a non ProtoGRPCMessage type.")
            }
            message.nestedMessages = newValue
        }
    }

    init(_ message: SomeGRPCMessage) {
        self.message = message
    }

    subscript<T>(dynamicMember member: KeyPath<SomeGRPCMessage, T>) -> T {
        message[keyPath: member]
    }

    func tryTyped<Message: SomeGRPCMessage>(for type: Message.Type = Message.self) -> Message? {
        message as? Message
    }

    var renderableContent: String {
        ""
        if let comments = message.sourceCodeComments {
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
            "\(context.options.visibility) static let protoMessageName: String = \"\(message.name)\"" // TODO respect parent descriptor file + file package name!

            if message.fields.isEmpty {
                "\(context.options.visibility) static let _protobuf_nameMap = \(moduleName)._NameMap()"
            } else {
                "\(context.options.visibility) static let _protobuf_nameMap: \(moduleName)._NameMap = ["
                Indent {
                    Joined(by: ",") { // TODO does the joined work here?
                        for field in message.fields {
                            "\(field.number): \(field.fieldMapNames)"
                        }
                    }
                }
                "]"
            }
            // TODO isInitialized?

            decodeMessageMethod
            ""
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
            "while let \(message.fields.isEmpty ? "_" : "fieldNumber") = try decoder.nextFieldNumber() {"
            Indent {
                // TODO print https://github.com/apple/swift-protobuf/issues/1034
                "switch fieldNumber {"
                Indent {
                    for field in message.sortedFields where !field.unavailable { // filtering out removed properties
                        field.fieldDecodeCase // TODO handle migration!
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
        "\(context.options.visibility) traverse<V: \(context.namer.swiftProtobufModuleName).Visitor>(visitor: inout V) throws {"
        Indent {
            if message.fields.contains { $0.generateTraverseUsesLocals } {
                // TODO  "// The use of inline closures is to circumvent an issue where the compiler\n",
                //          "// allocates stack space for every if/case branch local when no optimizations\n",
                //          "// are enabled. https://github.com/apple/swift-protobuf/issues/1034 and\n",
                //          "// https://github.com/apple/swift-protobuf/issues/1182\n")
            }

            for field in message.sortedFields {
                field.traverseExpression // TODO handle migration!
            }
            ""
            "try unknownFields.traverse(visitor: %visitor)"
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
                "public func encode(to encoder: Encoder) throws {"
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
                "public init(from decoder: Decoder) throws {"
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
