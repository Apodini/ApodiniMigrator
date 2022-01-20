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

struct ApodiniMessageField: SomeGRPCMessageField {
    private let property: TypeProperty
    let context: ProtoFileContext

    var hasFieldPresence: Bool

    // TODO check if this yields the same
    var name: String
    var privateName: String {
        "_" + name
    }
    var storedProperty: String {
        hasFieldPresence ? privateName : name
    }
    var propertyHasName: String {
        "has" + name.upperFirst
    }
    var funcClearName: String {
        "clear" + name.upperFirst
    }

    var type: Google_Protobuf_FieldDescriptorProto.TypeEnum

    var typeName: String
    var storageType: String
    var defaultValue: String
    var traitsType: String
    var protoGenericType: String

    var sourceCodeComments: String?

    var number: Int

    var fieldMapNames: String {
        ".same(proto: \"\(name)\")"
    }

    var isMap: Bool
    var isPacked: Bool
    var isRepeated: Bool

    init(_ property: TypeProperty, number: Int, defaultValue: Int? = nil, context: ProtoFileContext) {
        // we ignore fluent property annotations
        self.property = property
        self.context = context

        self.name = property.name

        self.type = property.protoType

        let typeName = property.swiftType(namer: context.namer)

        self.typeName = typeName
        self.storageType = property.swiftStorageType(namer: context.namer)
        if let defaultValue = defaultValue {
            self.defaultValue = "(try! \(typeName).instance(from: \(defaultValue)))"
        } else {
            self.defaultValue = property.swiftDefaultValue(namer: context.namer)
        }
        self.traitsType = property.traitsType(namer: context.namer)
        self.protoGenericType = property.deriveProtoGenericType()

        self.sourceCodeComments = nil

        self.number = number

        let type = property.type
        self.hasFieldPresence = property.hasPresence
        self.isMap = type.isDictionary
        self.isPacked = false // TODO can we just assume this? https://developers.google.com/protocol-buffers/docs/encoding#packed
        self.isRepeated = type.isRepeated
    }
}

extension TypeProperty: FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        type.protoType
    }

    var label: Google_Protobuf_FieldDescriptorProto.Label {
        if type.isRepeated {
            return .repeated
        } else if type.isOptional || necessity == .optional { // TODO proto2?
            return .optional
        } else {
            return .required
        }
    }

    var explicitDefaultValue: String? {
        // users can't provide explicit default value via the TypeInfo framework
        nil
    }

    var isMap: Bool {
        type.isMap
    }

    var hasPresence: Bool {
        type.isOptional || necessity == .optional
    }

    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? {
        type.mapKeyAndValueDescription
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        type.retrieveFullName(namer: namer)
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        type.enumDefaultValueDottedRelativeName(namer: namer, for: caseValue)
    }
}

extension TypeInformation {
    /// Returns the `Google_Protobuf_FieldDescriptorProto.TypeEnum` of a given `TypeInformation` instance.
    ///
    /// This replicates https://github.com/Apodini/Apodini/blob/98363c4e3f4c692ce15fe7bf7c6d1e32f0f6b8c0/Sources/ProtobufferCoding/ProtoCoding.swift#L225-L249
    var protoFieldType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        // TODO depending on custom conformances this might still yield wrong results
        switch self {
        case let .scalar(primitiveType):
            return primitiveType.protoFieldType
        case let .repeated(element):
            return element.protoFieldType
        case let .dictionary(key, value):
            // while proto maps this to a message with two properties (key and value), swift source code
            // generation will properly generate a Dictionary out of it!
            // TODO this maps to message right?
            return .message
        case let .optional(wrappedValue):
            return wrappedValue.protoFieldType
        case .enum:
            return .enum
        case .object:
            return .message
        case .reference:
            fatalError("Can't derive `protoFieldType` for .reference type!")
        }
    }
}

extension TypeInformation: FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        protoFieldType
    }

    var label: Google_Protobuf_FieldDescriptorProto.Label {
        if self.isRepeated {
            return .repeated
        } else if self.isOptional { // TODO proto2?
            return .optional
        } else {
            return .required
        }
    }

    var explicitDefaultValue: String? {
        nil
    }

    var isMap: Bool {
        isDictionary
    }

    var hasPresence: Bool {
        isOptional
    }

    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? {
        switch self {
        case let .dictionary(key, value):
            return (key, value)
        default:
            return nil
        }
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        // TODO is this sync?
        switch self {
        case .enum, .object:
            return typeName.buildName(componentSeparator: ".")
        default:
            return nil
        }
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        switch self {
        case .enum:
            if let caseValue = caseValue {
                for enumCase in enumCases where enumCase.rawValue == caseValue {
                    return "." + enumCase.name
                }
                return nil
            }

            return "." + enumCases.first.unsafelyUnwrapped.name
        default:
            return nil
        }
    }
}

// TODO placement!
extension PrimitiveType: FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        protoFieldType
    }

    var label: Google_Protobuf_FieldDescriptorProto.Label {
        .required
    }

    var explicitDefaultValue: String? {
        nil
    }

    var isMap: Bool {
        false
    }

    var hasPresence: Bool {
        label == .optional
    }

    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? {
        nil
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        nil
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        nil
    }
}

extension PrimitiveType {
    /// See https://github.com/Apodini/Apodini/blob/98363c4e3f4c692ce15fe7bf7c6d1e32f0f6b8c0/Sources/ProtobufferCoding/ProtoCoding.swift#L225-L249
    var protoFieldType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        switch self {
        case .null:
            fatalError("Can't handle NULL primitive type!")
        case .bool:
            return .bool
        case .int:
            return .int64
        case .int32:
            return .int32
        case .int64:
            return .int64
        case .uint:
            return .uint64
        case .uint32:
            return .uint32
        case .uint64:
            return .uint64
        case .string:
            return .string
        case .double:
            return .double
        case .float:
            return .float
        case .date:
            // TODO this is mapped to a `message Date { double _time = 1; }`
            //  problem is that `Date` must be generated accordingly!
            fatalError("Dates are currently unsupported!")
            return .message
        case .data:
            return .bytes
        case .int8,
             .int16,
             .uint8,
             .uint16,
             .uuid,
             .url:
            // those primitive types are all unsupported by ApodiniGRPC
            fatalError("PrimitiveType is unsupported by ApodiniGRPC: \(self)")
        }
    }
}
