//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ApodiniMigrator

protocol GRPCMethodRenderable { // TODO remove?
    @SourceCodeBuilder
    var clientProtocolSignature: String { get }

    @SourceCodeBuilder
    var clientProtocolExtensionFunction: String { get }

    @SourceCodeBuilder
    var clientProtocolExtensionSafeWrappers: String { get }
}

extension GRPCMethodRenderable where Self: GRPCMethodRepresentable {
    @SourceCodeBuilder
    private var unavailableAnnotation: String {
        if unavailable {
            let message = "This method is not available in the new version anymore. Calling this method will fail!"
            "@available(*, deprecated, message: \"\(message)\")"
        }
    }

    @SourceCodeBuilder
    var clientProtocolSignature: String {
        var arguments: [String] = []
        switch streamingType {
        case .unary, .serverStreaming:
            arguments = [
                "_ request: \(inputMessageName)",
                "callOptions: \(Types.clientCallOptions)?"
            ]

        case .clientStreaming, .bidirectionalStreaming:
            arguments = [
                "callOptions: \(Types.clientCallOptions)?"
            ]
        }

        unavailableAnnotation
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

        unavailableAnnotation
        SwiftFunction(
            name: "make\(methodMakeFunctionName)Call",
            arguments: arguments,
            returnType: "\(callType)<\(inputMessageName), \(outputMessageName)>",
            access: access
        ) {
            // TODO we will rise deprecation warning when calling self!
            "self.make\(callTypeWithoutPrefix)("
            Indent {
                "path: \"\(methodPath)\","
                if hasRequest {
                    "request: request,"
                }
                "callOptions: callOptions ?? defaultCallOptions"
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

            if let comments = sourceCodeComments {
                comments.dropFirst() // TODO why to we drop lol?
                comments // placing comments into source code!
            }

            unavailableAnnotation
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
                }
                ")"
            }
        }
    }
}
