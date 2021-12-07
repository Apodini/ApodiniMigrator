//
// Created by Andreas Bauer on 06.12.21.
//

import Foundation

public enum ApodiniExporterType: Value {
    case rest
    case http
    case gRPC
}

public protocol ExporterConfiguration {
    var type: ApodiniExporterType { get }
}

public struct RESTExporterConfiguration: ExporterConfiguration, Value {
    public let type: ApodiniExporterType

    /// Encoder configuration
    public var encoderConfiguration: EncoderConfiguration
    /// Decoder configuration
    public var decoderConfiguration: DecoderConfiguration

    public init(encoderConfiguration: EncoderConfiguration, decoderConfiguration: DecoderConfiguration) {
        self.type = .rest
        self.encoderConfiguration = encoderConfiguration
        self.decoderConfiguration = decoderConfiguration
    }
}
