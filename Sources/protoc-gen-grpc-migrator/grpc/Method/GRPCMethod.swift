//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

@dynamicMemberLookup
struct GRPCMethod: SourceCodeRenderable {
    enum SequenceProtocol: String {
        case sequence = "Sequence"
        case asyncSequence = "AsyncSequence"
    }

    private let method: SomeGRPCMethod
    let options: PluginOptions

    var requestParameterType: String {
        method.streamingType.isStreamingRequest
            ? "RequestStream" // generic with `where RequestStream: {sequenceProtocol}, RequestStream.Element == {inputMessageName}`
            : method.inputMessageName
    }

    init(_ method: SomeGRPCMethod, options: PluginOptions) {
        self.method = method
        self.options = options
    }

    subscript<T>(dynamicMember member: KeyPath<SomeGRPCMethod, T>) -> T {
        method[keyPath: member]
    }

    func tryTyped<Method: SomeGRPCMethod>(as type: Method.Type = Method.self) -> Method? {
        method as? Method
    }

    var renderableContent: String {
        // for streaming requests, the client can provide the request as `Sequence` or as `AsyncSequence`
        let sequenceProtocols: [SequenceProtocol?] = method.streamingType.isStreamingRequest
            ? [.sequence, .asyncSequence]
            : [nil]

        var generics: [String] = []
        if method.streamingType.isStreamingRequest {
            generics.append("RequestStream")
        }

        for sequenceProtocol in sequenceProtocols {
            // TODO remove first spacing!
            EmptyLine()

            if let comments = method.sourceCodeComments {
                comments.dropFirst() // TODO why to we drop lol?
                comments // placing comments into source code!
            }

            if method.unavailable {
                let message = "This method is not available in the new version anymore. Calling this method will fail!"
                "@available(*, deprecated, message: \"\(message)\")"
            }
            SwiftFunction(
                name: method.methodWrapperFunctionName,
                generics: generics,
                arguments: [
                    "_ \(method.streamingType.requestParameterName): \(requestParameterType)",
                    "callOptions: CallOptions? = nil"
                ],
                // TODO update repsonse on migration!
                returnType: method.streamingType.isStreamingResponse
                    ? "GRPCResponseStream<\(method.outputMessageName)>"
                    : method.outputMessageName,
                access: options.visibility.description,
                async: !method.streamingType.isStreamingResponse, // we return AsyncSequence instantly on streaming response!
                throws: !method.streamingType.isStreamingResponse,
                whereClause: sequenceProtocol.map {
                    "where RequestStream: \($0), RequestStream.Element == \(method.inputMessageName)"
                }
            ) {
                RequestMethodBody(for: method, sequence: sequenceProtocol)
            }
        }
    }

    struct RequestMethodBody: SourceCodeRenderable {
        let method: SomeGRPCMethod
        let sequence: SequenceProtocol?

        init(for method: SomeGRPCMethod, sequence: SequenceProtocol? = nil) {
            self.method = method
            self.sequence = sequence
        }

        var renderableContent: String {
            var updatedStreamingType: StreamingType = method.streamingType
            if let change = method.communicationPatternChange {
                precondition(StreamingType(from: change.from) == method.streamingType)
                updatedStreamingType = StreamingType(from: change.to)
            }

            var alreadyBuiltCall = false

            switch (method.streamingType.isStreamingRequest, updatedStreamingType.isStreamingRequest) {
            case (true, false): // requests -> request
                if method.streamingType.isStreamingResponse {
                    "let result = GRPCResponseStream(wrapping: \(sequence == .sequence ? "AsyncThrowingSequence(wrapping: requests)": "requests")"
                    Indent {
                        ".flatMap { element in"
                        Indent {
                            GRPCCall(for: method, streamingType: updatedStreamingType)
                            alreadyBuiltCall = true
                        }
                        "})"
                    }
                    // "return result" is generated below
                } else {
                    // TODO add deprecation warning, that it might throw in certain conditions!
                    "let stream = \(sequence == .sequence ? "AsyncThrowingSequence(wrapping: requests)": "requests")"
                    Indent {
                        ".map { request -> \(method.outputMessageName) in"
                        Indent {
                            GRPCCall(for: method, streamingType: updatedStreamingType)
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

            if !alreadyBuiltCall || (method.streamingType.isStreamingResponse, updatedStreamingType.isStreamingResponse) != (true, false) {
                // unless its a conversion from `\(outputMessageName) -> GRPCResponseStream` build the call
                // we need to handle that single case differently, as we aren't in a `async throws` context
                // and therefore need to wrap that thing into Task and try-catch.
                GRPCCall(for: method, streamingType: updatedStreamingType)
            }

            switch (method.streamingType.isStreamingResponse, updatedStreamingType.isStreamingResponse) {
            case (true, false): // GRPCAsyncResponseStream -> \(outputMessageName)
                "return GRPCResponseStream { continuation in"
                Indent {
                    "Task.detached {"
                    Indent {
                        "do {"
                        Indent {
                            GRPCCall(for: method, streamingType: method.streamingType)
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
            case (false, true): // \(outputMessageName) -> GRPCResponseStream
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
            case (true, true):
                // convert to our custom AsyncSequence wrapper type (required as we can't instantiate a GRPCAsyncResponseStream)
                "return GRPCResponseStream(wrapping: result)"
            default:
                "return result"
            }

            // TODO response type migration (if its not just a rename!)
        }
    }

    struct GRPCCall: SourceCodeRenderable {
        let method: SomeGRPCMethod
        let streamingType: StreamingType

        init(for method: SomeGRPCMethod, streamingType: StreamingType) {
            self.method = method
            self.streamingType = streamingType
        }

        var renderableContent: String {
            "let result = "
                + (!streamingType.isStreamingResponse ? "try await ": "")
                + "perform\(streamingType.grpcCallTypeString)("

            Indent {
                """
                path: \"\(method.updatedMethodPath ?? method.methodPath)\",
                \(streamingType.requestParameterName): \(streamingType.requestParameterName),
                callOptions: callOptions ?? defaultCallOptions,
                responseType: \(method.outputMessageName).self
                """
            }
            ")"
        }
    }
}
