//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct RESTExporterConfiguration: ExporterConfiguration {
    public static var type: ApodiniExporterType {
        .rest
    }

    /// Encoder configuration
    public var encoderConfiguration: EncoderConfiguration
    /// Decoder configuration
    public var decoderConfiguration: DecoderConfiguration
    public var caseInsensitiveRouting: Bool
    /// The entry point to the REST web service
    public var rootPath: String?

    public init(
        encoderConfiguration: EncoderConfiguration,
        decoderConfiguration: DecoderConfiguration,
        caseInsensitiveRouting: Bool = false,
        rootPath: String? = nil
    ) {
        self.encoderConfiguration = encoderConfiguration
        self.decoderConfiguration = decoderConfiguration
        self.caseInsensitiveRouting = caseInsensitiveRouting
        self.rootPath = rootPath
    }
}
