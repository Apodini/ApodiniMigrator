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
    let context: ProtoFileContext

    var requestParameterType: String {
        method.streamingType.isStreamingRequest
            ? "RequestStream" // generic with `where RequestStream: {sequenceProtocol}, RequestStream.Element == {inputMessageName}`
            : method.inputMessageName
    }

    init(_ method: SomeGRPCMethod, context: ProtoFileContext) {
        self.method = method
        self.context = context
    }

    func registerRemovalChange(_ change: EndpointChange.RemovalChange) {
        method.registerRemovalChange(change)
    }

    func registerUpdateChange(_ change: EndpointChange.UpdateChange) {
        method.registerUpdateChange(change)
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

        for sequenceProtocol in sequenceProtocols {
            EmptyLine()

            if var comments = method.sourceCodeComments, !comments.isEmpty {
                _ = comments.removeLast() // removing last trailing "\n"
                comments
            }

            if method.unavailable {
                // this is the only thing what we do when removing a method.
                // we rely on the web service to return its "standard" non-found error.
                // Most likely, a client library has a handler to catch the non-found error of the web service,
                // but it won't expect a custom error from our side which we would introduce to signal "not found".
                // Therefore, the risk of stuff not breaking things is lower if we rely on the web service to generate this error.

                let message = "This method is not available in the new version anymore. Calling this method will fail!"
                "@available(*, deprecated, message: \"\(message)\")"
            }
            SwiftFunction(
                name: method.methodWrapperFunctionName,
                generics: method.streamingType.isStreamingRequest ? ["RequestStream"] : [],
                arguments: [
                    "_ \(method.streamingType.requestParameterName): \(requestParameterType)",
                    "callOptions: CallOptions? = nil"
                ],
                returnType: method.streamingType.isStreamingResponse
                    ? "GRPCResponseStream<\(method.outputMessageName)>"
                    : method.outputMessageName,
                access: context.options.visibility.description,
                async: !method.streamingType.isStreamingResponse, // we return AsyncSequence instantly on streaming response!
                throws: !method.streamingType.isStreamingResponse,
                whereClause: sequenceProtocol.map {
                    "where RequestStream: \($0.rawValue), RequestStream.Element == \(method.inputMessageName)"
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
            var parameterMigration: String? = nil // swiftlint:disable:this redundant_optional_initialization
            // this closure is used to insert a call to the response migration closure generated below
            var responseMigration: (String) -> String = { $0 }
            var alreadyBuiltCall = false

            if let change = method.communicationPatternChange {
                precondition(StreamingType(from: change.from) == method.streamingType)
                updatedStreamingType = StreamingType(from: change.to)
            }

            if let typeChange = method.parameterChange {
                var `try` = "try"

                if method.streamingType.isStreamingResponse && updatedStreamingType.isStreamingResponse {
                    // workaround for now as we don't have an throws context available.
                    // we could in theory, as we stream response, wrap the migration into the AsyncSequence response
                    // but this makes everything even more complicated
                    `try` = "try!"
                }

                let migrationLine = { (name: String) -> String in
                    // swiftlint:disable:next force_unwrapping
                    "\(`try`) \(method.updatedInputMessageName!).from(\(name), script: \(typeChange.forwardMigration))"
                }

                if method.streamingType.isStreamingRequest {
                    parameterMigration = """
                                         let requests = \(sequence == .sequence ? "\(`try`) ": "")\
                                         requests.compactMap { \(migrationLine("$0")) }
                                         """
                } else {
                    parameterMigration = "let request = \(migrationLine("request"))"
                }
            }

            if let change = method.responseChange {
                "let migrateResponse: (\(method.updatedOutputMessageName!)) throws -> \(method.outputMessageName) = {"
                Indent("try \(method.outputMessageName).from($0, script: \(change.backwardsMigration))")
                "}"
                responseMigration = {
                    "try migrateResponse(\($0))"
                }
            }

            switch (method.streamingType.isStreamingRequest, updatedStreamingType.isStreamingRequest) {
            case (true, false): // requests -> request
                if updatedStreamingType.isStreamingResponse {
                    "let stream = GRPCResponseStream(wrapping: \(sequence == .sequence ? "AsyncThrowingStream(wrapping: requests)": "requests")"
                    Indent {
                        ".flatMap { request -> GRPCAsyncResponseStream<\(method.outputMessageName)> in"
                        Indent {
                            GRPCCall(for: method, streamingType: updatedStreamingType, parameterMigration: parameterMigration)
                            alreadyBuiltCall = true
                            "return result"
                        }
                        "})"
                    }
                } else {
                    "let stream = \(sequence == .sequence ? "AsyncThrowingStream(wrapping: requests)": "requests")"
                    Indent {
                        ".map { request -> \(method.outputMessageName) in"
                        Indent {
                            GRPCCall(for: method, streamingType: updatedStreamingType, parameterMigration: parameterMigration)
                            alreadyBuiltCall = true
                            "return result"
                        }
                        "}"
                    }
                }

                if !method.streamingType.isStreamingResponse {
                    "var iterator = stream.makeAsyncIterator()"
                    "guard let result = try await iterator.next() else {"
                    Indent("throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)")
                    "}"
                } else {
                    "let result = GRPCResponseStream(wrapping: stream)"
                }

                // "return result" is generated below
            case (false, true): // request -> requests
                "let requests = [request]"
            default:
                EmptyComponent() // did not change
            }

            let goingToGenerateCallLater = (method.streamingType.isStreamingResponse, updatedStreamingType.isStreamingResponse) == (true, false)
            if !alreadyBuiltCall && !goingToGenerateCallLater {
                // unless its a conversion from `\(outputMessageName) -> GRPCResponseStream` build the call
                // we need to handle that single case differently, as we aren't in a `async throws` context
                // and therefore need to wrap that thing into Task and try-catch.
                GRPCCall(for: method, streamingType: updatedStreamingType, parameterMigration: parameterMigration)
            }

            if !alreadyBuiltCall {
                switch (method.streamingType.isStreamingResponse, updatedStreamingType.isStreamingResponse) {
                case (true, false): // GRPCAsyncResponseStream -> \(outputMessageName)
                    "return GRPCResponseStream { continuation in"
                    Indent {
                        "Task.detached {"
                        Indent {
                            "do {"
                            Indent {
                                GRPCCall(for: method, streamingType: updatedStreamingType, parameterMigration: parameterMigration)
                                "continuation.yield(\(responseMigration("result")))"
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
                    """
                    var iterator = result.makeAsyncIterator()
                    guard let response = try await iterator.next() else {
                    """
                    Indent("throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)")
                    """
                    }
                    return \(responseMigration("response"))
                    """
                case (true, true):
                    // convert to our custom AsyncSequence wrapper type (required as we can't instantiate a GRPCAsyncResponseStream)
                    if method.responseChange != nil {
                        "return GRPCResponseStream(wrapping: result.compactMap { \(responseMigration("$0")) })"
                    } else {
                        "return GRPCResponseStream(wrapping: result)"
                    }
                default:
                    "return \(responseMigration("result"))"
                }
            } else {
                "return \(responseMigration("result"))"
            }
        }
    }

    struct GRPCCall: SourceCodeRenderable {
        let method: SomeGRPCMethod
        let streamingType: StreamingType
        let parameterMigration: String?

        init(for method: SomeGRPCMethod, streamingType: StreamingType, parameterMigration: String?) {
            self.method = method
            self.streamingType = streamingType
            self.parameterMigration = parameterMigration
        }

        var renderableContent: String {
            if let parameterMigration = parameterMigration {
                parameterMigration
            }

            "let result = "
                + (!streamingType.isStreamingResponse ? "try await ": "")
                + "perform\(streamingType.grpcCallTypeString)("

            Indent {
                """
                path: \"\(method.updatedMethodPath ?? method.methodPath)\",
                \(streamingType.requestParameterName): \(streamingType.requestParameterName),
                callOptions: callOptions ?? defaultCallOptions,
                responseType: \(method.updatedOutputMessageName ?? method.outputMessageName).self
                """
            }
            ")"
        }
    }
}
