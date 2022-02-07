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
            return .message // ApodiniGRPC uses SwiftProtobuf.Google_Protobuf_Timestamp
        case .uuid, .url: // TODO how is this handled with our migration stuff?
            return .string // ApodiniGRPC uses a string in the encoding!
        case .data:
            return .bytes
        case .int8,
             .int16,
             .uint8,
             .uint16:
            // those primitive types are all unsupported by ApodiniGRPC
            fatalError("PrimitiveType is unsupported by ApodiniGRPC: \(self)")
        }
    }
}

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
