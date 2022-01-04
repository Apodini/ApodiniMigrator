//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary
import ApodiniMigrator

struct GRPCMethod {
    private unowned let service: GRPCService
    private let method: MethodDescriptor

    var methodPath: String {
        "\(service.servicePath)/\(method.name)"
    }


    // TODO placement
    internal func sanitize(fieldName string: String) -> String {
        if quotableFieldNames.contains(string) {
            return "`\(string)`"
        }
        return string
    }


    var methodMakeFunctionName: String {
        var name = method.name
        // TODO keepMethodCasing
        name = name.prefix(1).uppercased() + name.dropFirst()
        return sanitize(fieldName: name)
    }

    var methodWrapperFunctionName: String {
        var name = method.name
        // TODO keepMethodCasing!
        // if !self.options.keepMethodCasing {
        //      name = name.prefix(1).lowercased() + name.dropFirst()
        //    }
        name = name.prefix(1).lowercased() + name.dropFirst()
        return sanitize(fieldName: name)
    }

    var streamingType: StreamingType {
        switch (method.proto.clientStreaming, method.proto.serverStreaming) {
        case (true, true):
            return .bidirectionalStreaming
        case (true, false):
            return .clientStreaming
        case (false, true):
            return .serverStreaming
        case (false, false):
            return .unary
        }
    }

    var callType: String {
        // TODO make this part of the streamingType overload
        Types.call(for: streamingType)
    }

    var callTypeWithoutPrefix: String {
        Types.call(for: streamingType, withGRPCPrefix: false)
    }

    var inputMessageName: String {
        service.protobufNamer.fullName(message: method.inputType)
    }

    var outputMessageName: String {
        service.protobufNamer.fullName(message: method.outputType)
    }

    init(_ method: MethodDescriptor, locatedIn service: GRPCService) {
        self.service = service
        self.method = method
    }

    @SourceCodeBuilder
    var clientProtocolSignature: String {
        var arguments: [String] = []
        switch streamingType {
        case .unary, .serverStreaming:
            arguments = [
                "_ request: \(inputMessageName)",
                "callOptions: \(Types.clientCallOptions)?",
            ]

        case .clientStreaming, .bidirectionalStreaming:
            arguments = [
                "callOptions: \(Types.clientCallOptions)?",
            ]
        }

        SwiftFunction(
            name: "make\(methodMakeFunctionName)Call",
            arguments: arguments,
            returnType: "\(callType)<\(inputMessageName), \(outputMessageName)>"
        )
    }

    @SourceCodeBuilder
    var clientProtocolExtensionFunction: String {
        let access: String? = nil
        let hasRequest: Bool = streamingType == .unary || streamingType == .serverStreaming

        var arguments: [String] = []
        if hasRequest {
            arguments.append("_ request: \(inputMessageName)")
        }
        arguments.append("callOptions: \(Types.clientCallOptions)? = nil")

        SwiftFunction(
            name: "make\(methodMakeFunctionName)Call",
            arguments: arguments,
            returnType: "\(callType)<\(inputMessageName), \(outputMessageName)>",
            access: access
        ) {
            "self.make\(callTypeWithoutPrefix)("
            Indent {
                "path: \"\(methodPath)\","
                if hasRequest {
                    "request: request,"
                }
                "callOptions: callOptions ?? defaultCallOptions"
                // TODO interceptors: []
            }
            ")"
        }
    }

    @SourceCodeBuilder
    var clientProtocolExtensionSafeWrappers: String {
        let sequenceProtocols: [String?] = streamingType.isStreamingRequest ? ["Sequence", "AsyncSequence"] : [nil]

        for sequenceProtocol in sequenceProtocols {
            // TODO remove first spacing!
            EmptyLine()

            let requestParameterName = streamingType.isStreamingRequest
                ? "requests"
                : "request"
            let requestParameterType = streamingType.isStreamingRequest
                ? "RequestStream"
                : inputMessageName

            let comments = method.protoSourceComments()
            comments.dropFirst()
            comments // placing comments into source code!

            SwiftFunction(
                name: streamingType.isStreamingRequest
                    ? "\(methodWrapperFunctionName)<RequestStream>"
                    : methodWrapperFunctionName,
                arguments: [
                    "_ \(requestParameterName): \(requestParameterType)",
                    "callOptions: \(Types.clientCallOptions)? = nil"
                ],
                returnType: streamingType.isStreamingResponse
                    ? Types.responseStream(of: outputMessageName)
                    : outputMessageName,
                access: "internal", // TODO access
                async: !streamingType.isStreamingResponse,
                throws: !streamingType.isStreamingResponse,
                whereClause: sequenceProtocol.map {
                    "where RequestStream: \($0), RequestStream.Element == \(inputMessageName)"
                }
            ) {
                (!streamingType.isStreamingResponse ? "try await ": "") + "perform\(callTypeWithoutPrefix)("
                Indent {
                    """
                    path: \"\(methodPath)\",
                    \(requestParameterName): \(requestParameterName),
                    callOptions: callOptions ?? defaultCallOptions
                    """
                    // TODO interceptors!
                }
                ")"
            }
        }
    }
}
