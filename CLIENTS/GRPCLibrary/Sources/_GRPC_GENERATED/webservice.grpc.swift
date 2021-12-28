// DO NOT EDIT.
//
// This file is machine generated!

import NIO
import GRPC



/// APODINI-handler: Greeter
/// APODINI-identifier: Greeter.greetName
protocol GreeterAsyncClientProtocol: GRPCClient {
    var serviceName: String { get }
    
    func makeGreetNameCall(
        _ request: GreeterMessage,
        callOptions: CallOptions?
    ) -> GRPCAsyncUnaryCall<GreeterMessage, GreetingMessage>
}

extension GreeterAsyncClientProtocol {
    var serviceName: String {
        "Greeter"
    }
    
    func makeGreetNameCall(
        _ request: GreeterMessage,
        callOptions: CallOptions? = nil
    ) -> GRPCAsyncUnaryCall<GreeterMessage, GreetingMessage> {
        self.makeAsyncUnaryCall(
            path: "Greeter/greetName",
            request: request,
            callOptions: callOptions ?? defaultCallOptions
        )
    }
}

struct GreeterAsyncClient: GreeterAsyncClientProtocol {
    var channel: GRPCChannel
    var defaultCallOptions: CallOptions
    init(
        channel: GRPCChannel,
        defaultCallOptions: CallOptions = CallOptions()
    ) {
        self.channel = channel
        self.defaultCallOptions = defaultCallOptions
    }
}

extension GreeterAsyncClient {
    
    
    
    internal func greetName(
        _ request: GreeterMessage,
        callOptions: CallOptions? = nil
    ) async throws -> GreetingMessage {
        try await performAsyncUnaryCall(
            path: "Greeter/greetName",
            request: request,
            callOptions: callOptions ?? defaultCallOptions
        )
    }
}