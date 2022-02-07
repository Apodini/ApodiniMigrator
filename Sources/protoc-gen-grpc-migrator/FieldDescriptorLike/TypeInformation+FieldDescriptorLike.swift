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

extension TypeInformation {
    /// Returns the `Google_Protobuf_FieldDescriptorProto.TypeEnum` of a given `TypeInformation` instance.
    ///
    /// This replicates https://github.com/Apodini/Apodini/blob/98363c4e3f4c692ce15fe7bf7c6d1e32f0f6b8c0/Sources/ProtobufferCoding/ProtoCoding.swift#L225-L249
    var protoFieldType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        switch self {
        case let .scalar(primitiveType):
            return primitiveType.protoFieldType
        case let .repeated(element):
            return element.protoFieldType
        case .dictionary:
            // while proto maps this to a message with two properties (key and value), swift source code
            // generation will properly generate a Dictionary out of it!
            return .message
        case let .optional(wrappedValue):
            return wrappedValue.protoFieldType
        case .enum:
            return .enum
        case .object:
            return .message
        case .reference:
            fatalError("Can't derive `protoFieldType` for .reference type: \(self)")
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
        } else if self.isOptional {
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

    // TODO move magic constant!
    private static var emptyName: TypeName {
        TypeName(rawValue: "Apodini.Empty")
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        switch self {
            // repeated and optional are handled separately in the protobuf name builder
        case let .repeated(element):
            return element.retrieveFullName(namer: namer)
        case let .optional(wrappedValue):
            return wrappedValue.retrieveFullName(namer: namer)
        case let .object(name, _, context):
            if name == Self.emptyName {
                return "SwiftProtobuf.Google_Protobuf_Empty"
            }

            let grpcName = context.get(valueFor: TypeInformationIdentifierContextKey.self)
                .identifier(for: GRPCName.self)
                .parsed()

            return namer.fullName(message: grpcName)
        case let .enum(_, _, _, context):
            let grpcName = context.get(valueFor: TypeInformationIdentifierContextKey.self)
                .identifier(for: GRPCName.self)
                .parsed()

            return namer.fullName(enum: grpcName)
        case .scalar(.date):
            return "SwiftProtobuf.Google_Protobuf_Timestamp"
        default:
            return nil
        }
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        switch self {
        case let .optional(wrappedValue):
            return wrappedValue.enumDefaultValueDottedRelativeName(namer: namer, for: caseValue)
        case let .repeated(element):
            return element.enumDefaultValueDottedRelativeName(namer: namer, for: caseValue)
        case let .enum(_, _, cases, _):
            if let caseValue = caseValue {
                for enumCase in cases where enumCase.rawValue == caseValue {
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
