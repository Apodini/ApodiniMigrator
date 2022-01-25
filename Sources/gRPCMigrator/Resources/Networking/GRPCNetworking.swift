import NIO
import NIOSSL
import GRPC

open class GRPCNetworking {
    public static let verification: CertificateVerification = .none

    public static let hostname = ___HOSTNAME___
    public static let port = ___PORT___

    public let eventLoopGroup: EventLoopGroup

    private var _defaultChannel: GRPCChannel?
    public var defaultChannel: GRPCChannel {
        get throws {
            guard let channel = _defaultChannel else {
                let channel = try GRPCChannelPool.with(
                    target: .host(Self.hostname, port: Self.port),
                    transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL(certificateVerification: Self.verification)),
                    eventLoopGroup: eventLoopGroup
                )
                self._defaultChannel = channel
                return channel
            }

            return channel
        }
    }

    public init(eventLoopGroup: EventLoopGroup) {
        self.eventLoopGroup = eventLoopGroup
    }

    public func close() -> EventLoopFuture<Void> {
        guard let channel = _defaultChannel else {
            return eventLoopGroup.next().makeSucceededVoidFuture()
        }

        self._defaultChannel = nil
        return channel.close()
    }

    deinit {
        try! close().wait()
    }
}
