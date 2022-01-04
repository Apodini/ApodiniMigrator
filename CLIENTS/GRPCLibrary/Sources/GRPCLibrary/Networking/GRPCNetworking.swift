import Foundation
import NIO
import NIOSSL
import GRPC

public class GRPCNetworking {
    private let eventLoopGroup: EventLoopGroup

    private static let HOSTNAME = "127.0.0.1" // TODO CONFIG
    private static let PORT = 8080 // TODO CONFIG

    // TODO SSL Configuration CERT!
    private static let VERIFICATION: CertificateVerification = .none // TODO CONFIG

    private var _channel: ClientConnection?
    var channel: ClientConnection {
        guard let channel = _channel else {
            // TODO channelPools are now a thing in version 1.6.1
            let channel = ClientConnection
                .usingTLSBackedByNIOSSL(on: eventLoopGroup)
                .withTLS(certificateVerification: Self.VERIFICATION)
                .connect(host: Self.HOSTNAME, port: Self.PORT)
            self._channel = channel
            return channel
        }

        // TODO close channel when this object is destroyed

        return channel
    }

    // TODO GENERATED CLIENTS HERE!
    private var _greeterClient: GreeterAsyncClient?
    var greeterClient: GreeterAsyncClient {
        guard let client = _greeterClient else {
            let client = GreeterAsyncClient(channel: self.channel)
            self._greeterClient = client
            return client
        }

        return client
    }
    // TODO other generated clients!!

    public init(eventLoopGroup: EventLoopGroup) {
        self.eventLoopGroup = eventLoopGroup
    }

    // TODO upgrade to channel pools? once 1.5. arrives with async support!

    public func close() -> EventLoopFuture<Void> {
        guard let channel = _channel else {
            return eventLoopGroup.next().makeSucceededVoidFuture()
        }

        return channel.close()
    }

    deinit {
        try! close().wait()
    }
}
