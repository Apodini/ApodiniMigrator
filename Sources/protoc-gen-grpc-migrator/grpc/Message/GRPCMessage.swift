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

class GRPCMessage {
    let descriptor: Descriptor
    let namer: SwiftProtobufNamer

    var relativeName: String
    var fullName: String

    var unavailable = false // TODO set
    var containsRootTypeChange = false // TODO use!

    var fields: [GRPCMessageField] = []
    lazy var sortedFields: [GRPCMessageField] = {
        fields.sorted(by: \.number)
    }()

    var nestedEnums: OrderedDictionary<String, GRPCEnum> = [:]
    var nestedMessages: OrderedDictionary<String, GRPCMessage> = [:]

    init(descriptor: Descriptor, namer: SwiftProtobufNamer) {
        self.descriptor = descriptor
        self.namer = namer

        precondition(descriptor.extensionRanges.isEmpty, "proto extensions are unsupported by the migrator")

        self.relativeName = namer.relativeName(message: descriptor)
        self.fullName = namer.relativeName(message: descriptor)

        for field in descriptor.fields {
            fields.append(GRPCMessageField(descriptor: field, namer: namer))
        }

        for `enum` in descriptor.enums {
            nestedEnums[`enum`.name] = GRPCEnum(descriptor: `enum`, namer: namer)
        }

        for message in descriptor.messages {
            nestedMessages[message.name] = GRPCMessage(descriptor: message, namer: namer)
        }
    }

    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        // TODO deltaIdentifier verification!

        switch change.updated {
        case .rootType: // TODO model it as removal and addition?
            containsRootTypeChange = true // root type changes are unsupported
        case let .property(property):
            // TODO we ignore idChange right?
            if let addedProperty = property.modeledAdditionChange {
                // TODO how to we know the number? (guess?
            } else if let removedProperty = property.modeledRemovalChange {
                // TODO mark removed (just don't encode anymore?)
            } else if let updatedProperty = property.modeledUpdateChange {
                switch updatedProperty.updated {
                case let .necessity(from, to, necessityMigration):
                    // TODO update change!
                    break
                case let .type(from, to, forwardMigration, backwardMigration, conversionWarning):
                    // TODO first time handling type change!
                    // TODO requires Codable support!
                    break
                }
            }
        case .case, .rawValueType:
            fatalError("Tried updating message with enum-only change type!")
        }
    }

    @SourceCodeBuilder
    var primaryModelType: String {
        ""
        descriptor.protoSourceComments()
        if unavailable {
            "@available(*, message: \"This message was removed in the latest version!\")"
        }

        "public struct \(relativeName) {" // TODO visibility
        Indent {
            for field in fields {
                field.propertyInterface
            }

            ""
            "public var unknownFields = \(namer.swiftProtobufModuleName).UnknownStorage()"

            // TODO spacing!

            for `enum` in nestedEnums.values {
                `enum`.primaryModelType
            }

            for message in nestedMessages.values {
                message.primaryModelType
            }
        }
        "}"
    }

    @SourceCodeBuilder
    var protobufferRuntimeSupport: String {
        ""
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
            // TODO isInitialized?

            decodeMessageMethod
            ""
            traverseMessageMethod
        }
        "}"

        for `enum` in nestedMessages.values {
            `enum`.protobufferRuntimeSupport
        }

        for message in nestedMessages.values {
            message.protobufferRuntimeSupport
        }
    }

    @SourceCodeBuilder
    private var decodeMessageMethod: String {
        "public mutating func decodeMessage<D: \(namer.swiftProtobufModuleName).Decoder>(decoder: inout D) throws {"
        Indent {
            "while let \(fields.isEmpty ? "_" : "fieldNumber") = try decoder.nextFieldNumber() {"
            Indent {
                // TODO print https://github.com/apple/swift-protobuf/issues/1034
                "switch fieldNumber {"
                Indent {
                    for field in sortedFields {
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
            if fields.contains { $0.generateTraverseUsesLocals } {
                // TODO  "// The use of inline closures is to circumvent an issue where the compiler\n",
                //          "// allocates stack space for every if/case branch local when no optimizations\n",
                //          "// are enabled. https://github.com/apple/swift-protobuf/issues/1034 and\n",
                //          "// https://github.com/apple/swift-protobuf/issues/1182\n")
            }

            for field in sortedFields {
                field.traverseExpression
            }
            ""
            "try unknownFields.traverse(visitor: %visitor)"
        }
        "}"
    }
}
