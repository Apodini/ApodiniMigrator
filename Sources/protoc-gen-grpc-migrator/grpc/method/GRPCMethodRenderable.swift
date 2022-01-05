//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ApodiniMigrator

protocol GRPCMethodRenderable: GRPCMethodRepresentable { // TODO remove?
    @SourceCodeBuilder
    var clientProtocolExtensionSafeWrappers: String { get }
}

enum SequenceProtocol: String {
    case sequence = "Sequence"
    case asyncSequence = "AsyncSequence"
}

// TODO all the generation is bit weirdly placed?
extension GRPCMethodRenderable {
    var requestParameterType: String {
        streamingType.isStreamingRequest
            ? "RequestStream" // generic with `where RequestStream: {sequenceProtocol}, RequestStream.Element == {inputMessageName}`
            : inputMessageName
    }

    @SourceCodeBuilder
    var clientProtocolExtensionSafeWrappers: String {
        // for streaming requests, the client can provide the request as `Sequence` or as `AsyncSequence`
        let sequenceProtocols: [SequenceProtocol?] = streamingType.isStreamingRequest
            ? [.sequence, .asyncSequence]
            : [nil]

        var generics: [String] = []
        if streamingType.isStreamingRequest {
            generics.append("RequestStream")
        }

        // TODO sequence is wrapped into `AsyncStream(wrapping: requests)`

        for sequenceProtocol in sequenceProtocols {
            // TODO remove first spacing!
            EmptyLine()

            if let comments = sourceCodeComments {
                comments.dropFirst() // TODO why to we drop lol?
                comments // placing comments into source code!
            }

            if unavailable {
                let message = "This method is not available in the new version anymore. Calling this method will fail!"
                "@available(*, deprecated, message: \"\(message)\")"
            }
            SwiftFunction(
                name: methodWrapperFunctionName,
                generics: generics,
                arguments: [
                    "_ \(streamingType.requestParameterName): \(requestParameterType)",
                    "callOptions: CallOptions? = nil"
                ],
                // TODO update repsonse on migration!
                returnType: streamingType.isStreamingResponse
                    ? "GRPCResponseStream<\(outputMessageName)>"
                    : outputMessageName,
                access: "public", // TODO configurable access
                async: !streamingType.isStreamingResponse, // we return AsyncSequence instantly on streaming response!
                throws: !streamingType.isStreamingResponse,
                whereClause: sequenceProtocol.map {
                    "where RequestStream: \($0), RequestStream.Element == \(inputMessageName)"
                }
            ) {
                buildRequestMethodContent(sequence: sequenceProtocol)
            }
        }
    }

    func buildRequestMethodContent(sequence: SequenceProtocol?) -> String { // swiftlint:disable:this function_body_length
        // TODO parametrized result builder meh
        @SourceCodeBuilder
        var requestMethodContent: String {
            var updatedStreamingType: StreamingType = streamingType
            if let change = self.communicationPatternChange {
                precondition(StreamingType(from: change.from) == streamingType)
                updatedStreamingType = StreamingType(from: change.to)
            }

            var alreadyBuiltCall = false

            switch (streamingType.isStreamingRequest, updatedStreamingType.isStreamingRequest) {
            case (true, false): // requests -> request
                if streamingType.isStreamingResponse {
                    "let result = GRPCResponseStream(wrapping: \(sequence == .sequence ? "AsyncThrowingSequence(wrapping: requests)": "requests")"
                    Indent {
                        ".flatMap { element in"
                        Indent {
                            buildGRPCCall(streamingType: updatedStreamingType)
                            alreadyBuiltCall = true
                        }
                        "})"
                    }
                    // "return result" is generated below
                } else {
                    // TODO add deprecation warning, that it might throw in certain conditions!
                    "let stream = \(sequence == .sequence ? "AsyncThrowingSequence(wrapping: requests)": "requests")"
                    Indent {
                        ".map { request -> \(outputMessageName) in"
                        Indent {
                            buildGRPCCall(streamingType: updatedStreamingType)
                            alreadyBuiltCall = true
                        }
                        "}"
                    }

                    "var iterator = stream.makeAsyncIterator()"
                    "guard let result = try await iterator.next() else {"
                    Indent("throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)")
                    "}"
                    // "return result" is generated below
                }
            case (false, true): // request -> requests
                "let requests = [request]"
            default:
                EmptyComponent() // did not change
            }

            if (!alreadyBuiltCall || streamingType.isStreamingResponse, updatedStreamingType.isStreamingResponse) != (false, true) {
                // unless its a conversion from `\(outputMessageName) -> GRPCResponseStream` build the call
                // we need to handle that single case differently, as we aren't in a `async throws` context
                // and therefore need to wrap that thing into Task and try-catch.
                buildGRPCCall(streamingType: updatedStreamingType)
            }

            switch (streamingType.isStreamingResponse, updatedStreamingType.isStreamingResponse) {
            case (true, false): // GRPCAsyncResponseStream -> \(outputMessageName)
                // TODO add deprecation warning, that it might throw in certain conditions!

                """
                var iterator = result.makeAsyncIterator()
                guard let response = try await iterator.next() else {
                """
                Indent("throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)")
                """
                }
                guard try await iterator.next() == nil else {
                """
                Indent("throw GRPCNetworkingError.streamingTypeMigrationError(type: .didReceiveToManyResponses)")
                """
                }
                return response
                """
            case (false, true): // \(outputMessageName) -> GRPCResponseStream
                "return GRPCResponseStream { continuation in"
                Indent {
                    "Task.detached {"
                    Indent {
                        "do {"
                        Indent {
                            buildGRPCCall(streamingType: streamingType)
                            "continuation.yield(result)"
                            "continuation.finish()"
                        }
                        "} catch {"
                        Indent("continuation.finish(throwing: error)")
                        "}"
                    }
                    "}"
                }
                "}"
            case (true, true):
                // convert to our custom AsyncSequence wrapper type (required as we can't instantiate a GRPCAsnycResponseStream)
                "return GRPCResponseStream(wrapping: result)"
            default:
                "return result"
            }

            // TODO response type migration (if its not just a rename!)
        }
        return requestMethodContent
    }

    func buildGRPCCall(streamingType: StreamingType) -> String {
        // TODO parametrized result builder meh
        @SourceCodeBuilder
        var code: String {
            "let result = "
                + (!streamingType.isStreamingResponse ? "try await ": "")
                + "perform\(streamingType.grpcCallTypeString)("

            Indent {
                // TODO migration of methodPath
                """
                path: \"\(methodPath)\",
                \(streamingType.requestParameterName): \(streamingType.requestParameterName),
                callOptions: callOptions ?? defaultCallOptions,
                responseType: \(outputMessageName).self
                """
            }
            ")"
        }

        return code
    }
}
