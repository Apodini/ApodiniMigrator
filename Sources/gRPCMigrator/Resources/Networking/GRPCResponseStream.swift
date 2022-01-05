import Foundation
import GRPC

public struct GRPCResponseStream<Element>: AsyncSequence {
    public typealias Stream = AsyncThrowingStream<Element, Error>

    private let wrappedStream: Stream

    public init<Wrapped: AsyncSequence>(wrapping sequence: Wrapped) where Wrapped.Element == Element {
        self.wrappedStream = Stream(wrapping: sequence)
    }

    public init<Wrapped: Sequence>(wrapping sequence: Wrapped) where Wrapped.Element == Element {
        self.wrappedStream = Stream(wrapping: sequence)
    }

    public init(_ build: (Stream.Continuation) -> Void) {
        self.wrappedStream = AsyncThrowingStream(Element.self, build)
    }

    public init(stream: Stream) {
        self.wrappedStream = stream
    }

    public func makeAsyncIterator() -> Stream.Iterator {
        wrappedStream.makeAsyncIterator()
    }
}

extension AsyncThrowingStream {
    public init<Wrapped: AsyncSequence>(wrapping sequence: Wrapped) where Wrapped.Element == Element, Failure == Error {
        self = AsyncThrowingStream { continuation in
            Task.detached {
                do {
                    for try await value in sequence {
                        continuation.yield(value)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }

    public init<Wrapped: Sequence>(wrapping sequence: Wrapped) where Wrapped.Element == Element, Failure == Error {
        self = AsyncThrowingStream { continuation in
            for value in sequence {
                continuation.yield(value)
            }
            continuation.finish()
        }
    }
}
