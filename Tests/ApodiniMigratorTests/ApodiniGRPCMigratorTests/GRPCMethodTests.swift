//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
@testable import ApodiniMigratorCompare
@testable import ApodiniMigrator
@testable import gRPCMigrator
@testable import ProtocGRPCPluginLibrary
import ApodiniDocumentExport

extension CommunicationPattern {
    var others: [CommunicationPattern] {
        var cases = Self.allCases
        cases.remove(at: cases.firstIndex(of: self)!) // swiftlint:disable:this force_unwrapping
        return cases
    }
}

struct CommunicationPatternKey: Hashable {
    let from: CommunicationPattern
    let to: CommunicationPattern
}

struct MethodExpectation {
    let __normal: String // swiftlint:disable:this identifier_name
    let migrated: String
}

// swiftlint:disable:next type_body_length
final class GRPCMethodTests: ApodiniMigratorXCTestCase {
    func testMethod() throws {
        for from in CommunicationPattern.allCases {
            for to in from.others {
                let expectation = try XCTUnwrap(expectations[.init(from: from, to: to)])

                let stubMethod = StubGRPCMethod(streamingType: StreamingType(from: from))
                let method = GRPCMethod(stubMethod, context: .mock())

                let normal = method.renderableContent

                method.registerUpdateChange(.init(
                    id: stubMethod.deltaIdentifier,
                    updated: .communicationPattern(from: from, to: to),
                    breaking: true,
                    solvable: true
                ))

                let migrated = method.renderableContent

                XCTAssertEqual(normal, expectation.__normal)
                XCTAssertEqual(migrated, expectation.migrated)
            }
        }
    }

    // swiftlint:disable line_length
    let expectations: [CommunicationPatternKey: MethodExpectation] = [
        .init(from: .requestResponse, to: .clientSideStream): .init(
            __normal: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncUnaryCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """,
            migrated: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
                          let requests = [request]
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """
        ),
        .init(from: .requestResponse, to: .serviceSideStream): .init(
            __normal: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncUnaryCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """,
            migrated: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncServerStreamingCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          var iterator = result.makeAsyncIterator()
                          guard let response = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return response
                      }
                      """
        ),
        .init(from: .requestResponse, to: .bidirectionalStream): .init(
            __normal: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncUnaryCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """,
            migrated: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
                          let requests = [request]
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          var iterator = result.makeAsyncIterator()
                          guard let response = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return response
                      }
                      """
        ),
        .init(from: .clientSideStream, to: .requestResponse): .init(
            __normal: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """,
            migrated: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = AsyncThrowingStream(wrapping: requests)
                              .map { request -> SwiftProtobuf.Google_Protobuf_Empty in
                                  let result = try await performAsyncUnaryCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              }
                          var iterator = stream.makeAsyncIterator()
                          guard let result = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = requests
                              .map { request -> SwiftProtobuf.Google_Protobuf_Empty in
                                  let result = try await performAsyncUnaryCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              }
                          var iterator = stream.makeAsyncIterator()
                          guard let result = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return result
                      }
                      """
        ),
        .init(from: .clientSideStream, to: .serviceSideStream): .init(
            __normal: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """,
            migrated: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = GRPCResponseStream(wrapping: AsyncThrowingStream(wrapping: requests)
                              .flatMap { request -> GRPCAsyncResponseStream<SwiftProtobuf.Google_Protobuf_Empty> in
                                  let result = performAsyncServerStreamingCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              })
                          var iterator = stream.makeAsyncIterator()
                          guard let result = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = GRPCResponseStream(wrapping: requests
                              .flatMap { request -> GRPCAsyncResponseStream<SwiftProtobuf.Google_Protobuf_Empty> in
                                  let result = performAsyncServerStreamingCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              })
                          var iterator = stream.makeAsyncIterator()
                          guard let result = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return result
                      }
                      """
        ),
        .init(from: .clientSideStream, to: .bidirectionalStream): .init(
            __normal: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = try await performAsyncClientStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return result
                      }
                      """,
            migrated: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          var iterator = result.makeAsyncIterator()
                          guard let response = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return response
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) async throws -> SwiftProtobuf.Google_Protobuf_Empty where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          var iterator = result.makeAsyncIterator()
                          guard let response = try await iterator.next() else {
                              throw GRPCNetworkingError.streamingTypeMigrationError(type: .didNotReceiveAnyResponse)
                          }
                          return response
                      }
                      """
        ),
        .init(from: .serviceSideStream, to: .requestResponse): .init(
            __normal: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> {
                          let result = performAsyncServerStreamingCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """,
            migrated: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> {
                          return GRPCResponseStream { continuation in
                              Task.detached {
                                  do {
                                      let result = try await performAsyncUnaryCall(
                                          path: "/package.service/method",
                                          request: request,
                                          callOptions: callOptions ?? defaultCallOptions,
                                          responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                      )
                                      continuation.yield(result)
                                      continuation.finish()
                                  } catch {
                                      continuation.finish(throwing: error)
                                  }
                              }
                          }
                      }
                      """
        ),
        .init(from: .serviceSideStream, to: .clientSideStream): .init(
            __normal: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> {
                          let result = performAsyncServerStreamingCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """,
            migrated: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> {
                          let requests = [request]
                          return GRPCResponseStream { continuation in
                              Task.detached {
                                  do {
                                      let result = try await performAsyncClientStreamingCall(
                                          path: "/package.service/method",
                                          requests: requests,
                                          callOptions: callOptions ?? defaultCallOptions,
                                          responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                      )
                                      continuation.yield(result)
                                      continuation.finish()
                                  } catch {
                                      continuation.finish(throwing: error)
                                  }
                              }
                          }
                      }
                      """
        ),
        .init(from: .serviceSideStream, to: .bidirectionalStream): .init(
            __normal: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> {
                          let result = performAsyncServerStreamingCall(
                              path: "/package.service/method",
                              request: request,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """,
            migrated: """

                      internal func method(
                          _ request: SwiftProtobuf.Google_Protobuf_Empty,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> {
                          let requests = [request]
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """
        ),
        .init(from: .bidirectionalStream, to: .requestResponse): .init(
            __normal: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """,
            migrated: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = AsyncThrowingStream(wrapping: requests)
                              .map { request -> SwiftProtobuf.Google_Protobuf_Empty in
                                  let result = try await performAsyncUnaryCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              }
                          let result = GRPCResponseStream(wrapping: stream)
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = requests
                              .map { request -> SwiftProtobuf.Google_Protobuf_Empty in
                                  let result = try await performAsyncUnaryCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              }
                          let result = GRPCResponseStream(wrapping: stream)
                          return result
                      }
                      """
        ),
        .init(from: .bidirectionalStream, to: .clientSideStream): .init(
            __normal: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """,
            migrated: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          return GRPCResponseStream { continuation in
                              Task.detached {
                                  do {
                                      let result = try await performAsyncClientStreamingCall(
                                          path: "/package.service/method",
                                          requests: requests,
                                          callOptions: callOptions ?? defaultCallOptions,
                                          responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                      )
                                      continuation.yield(result)
                                      continuation.finish()
                                  } catch {
                                      continuation.finish(throwing: error)
                                  }
                              }
                          }
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          return GRPCResponseStream { continuation in
                              Task.detached {
                                  do {
                                      let result = try await performAsyncClientStreamingCall(
                                          path: "/package.service/method",
                                          requests: requests,
                                          callOptions: callOptions ?? defaultCallOptions,
                                          responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                      )
                                      continuation.yield(result)
                                      continuation.finish()
                                  } catch {
                                      continuation.finish(throwing: error)
                                  }
                              }
                          }
                      }
                      """
        ),
        .init(from: .bidirectionalStream, to: .serviceSideStream): .init(
            __normal: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let result = performAsyncBidirectionalStreamingCall(
                              path: "/package.service/method",
                              requests: requests,
                              callOptions: callOptions ?? defaultCallOptions,
                              responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                          )
                          return GRPCResponseStream(wrapping: result)
                      }
                      """,
            migrated: """

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: Sequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = GRPCResponseStream(wrapping: AsyncThrowingStream(wrapping: requests)
                              .flatMap { request -> GRPCAsyncResponseStream<SwiftProtobuf.Google_Protobuf_Empty> in
                                  let result = performAsyncServerStreamingCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              })
                          let result = GRPCResponseStream(wrapping: stream)
                          return result
                      }

                      internal func method<RequestStream>(
                          _ requests: RequestStream,
                          callOptions: CallOptions? = nil
                      ) -> GRPCResponseStream<SwiftProtobuf.Google_Protobuf_Empty> where RequestStream: AsyncSequence, RequestStream.Element == SwiftProtobuf.Google_Protobuf_Empty {
                          let stream = GRPCResponseStream(wrapping: requests
                              .flatMap { request -> GRPCAsyncResponseStream<SwiftProtobuf.Google_Protobuf_Empty> in
                                  let result = performAsyncServerStreamingCall(
                                      path: "/package.service/method",
                                      request: request,
                                      callOptions: callOptions ?? defaultCallOptions,
                                      responseType: SwiftProtobuf.Google_Protobuf_Empty.self
                                  )
                                  return result
                              })
                          let result = GRPCResponseStream(wrapping: stream)
                          return result
                      }
                      """
        )
    ]
    // swiftlint:enable line_length
}

// swiftlint:disable:this file_length
