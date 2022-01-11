//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobuf
import SwiftProtobufPluginLibrary

class ProtoGRPCMessageField: SomeGRPCMessageField, Changeable {
    let descriptor: FieldDescriptor

    let hasFieldPresence: Bool

    let name: String
    let privateName: String
    let storedProperty: String
    let propertyHasName: String
    let funcClearName: String

    let type: Google_Protobuf_FieldDescriptorProto.TypeEnum

    let typeName: String
    let storageType: String
    let defaultValue: String
    let traitsType: String
    let protoGenericType: String

    let sourceCodeComments: String?

    let number: Int

    var fieldMapNames: String {
        let protoName: String = descriptor.name
        let jsonName = descriptor.jsonName ?? protoName
        if jsonName == protoName {
            // The proto and JSON names are identical:
            return ".same(proto: \"\(protoName)\")"
        } else {
            let libraryGeneratedJsonName = NamingUtils.toJsonFieldName(protoName)
            if jsonName == libraryGeneratedJsonName {
                // The library will generate the same thing protoc gave, so
                // we can let the library recompute this:
                return ".standard(proto: \"\(protoName)\")"
            } else {
                // The library's generation didn't match, so specify this explicitly.
                return ".unique(proto: \"\(protoName)\", json: \"\(jsonName)\")"
            }
        }
    }

    var isMap: Bool {
        descriptor.isMap
    }
    var isPacked: Bool {
        descriptor.isPacked
    }

    // Note: this could still be a map (since those are repeated message fields
    var isRepeated: Bool {
        descriptor.label == .repeated
    }

    init(descriptor: FieldDescriptor, context: ProtoFileContext) {
        precondition(descriptor.protoType != .group, ".group field types are not supported!")
        self.descriptor = descriptor

        precondition(descriptor.realOneof == nil, "OneOfs aren't supported!")

        self.hasFieldPresence = descriptor.hasPresence && descriptor.realOneof == nil

        let names = context.namer.messagePropertyNames(field: descriptor, prefixed: "_", includeHasAndClear: hasFieldPresence)
        self.name = names.name
        self.privateName = names.prefixed
        self.storedProperty = hasFieldPresence ? privateName : name
        self.propertyHasName = names.has
        self.funcClearName = names.clear

        self.type = descriptor.protoType

        self.typeName = descriptor.swiftType(namer: context.namer)
        self.storageType = descriptor.swiftStorageType(namer: context.namer)
        self.defaultValue = descriptor.swiftDefaultValue(namer: context.namer)
        self.traitsType = descriptor.traitsType(namer: context.namer)
        self.protoGenericType = descriptor.deriveProtoGenericType()

        sourceCodeComments = descriptor.protoSourceComments()
        
        self.number = Int(descriptor.number)
    }

    func applyUpdateChange(_ change: PropertyChange.UpdateChange) {
        // TODO apply update!
        /*
         switch updatedProperty.updated {
                case let .necessity(from, to, necessityMigration):
                    // TODO update change!
                    break
                case let .type(from, to, forwardMigration, backwardMigration, conversionWarning):
                    // TODO first time handling type change!
                    // TODO requires Codable support!
                    break
                }
         */
    }

    func applyRemovalChange(_ change: PropertyChange.RemovalChange) {
        // TODO unavailable
    }
}

// TODO move into file!
extension FieldDescriptor: FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        type
    }

    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? {
        if let message = messageType,
           let map = message.mapKeyAndValue {
            return (map.key, map.value)
        }

        return nil
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        switch protoType {
        case .message,
             .group:
            return namer.fullName(message: messageType)
        case .enum:
            return namer.fullName(enum: enumType)
        default:
            return nil
        }
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        guard let enumType = enumType else {
            return nil
        }

        if let caseValue = caseValue {
            for value in enumType.values where value.name == caseValue {
                return namer.dottedRelativeName(enumValue: value)
            }
            return nil
        }

        return namer.dottedRelativeName(enumValue: enumType.defaultValue)
    }
}
