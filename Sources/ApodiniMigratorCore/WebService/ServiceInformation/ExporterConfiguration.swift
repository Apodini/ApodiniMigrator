//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum ApodiniExporterType: String, Value {
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
