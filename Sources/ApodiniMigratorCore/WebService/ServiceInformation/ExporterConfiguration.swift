//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension ApodiniExporterType: Value {
    public func anyDecode<Key>(from container: KeyedDecodingContainer<Key>, forKey key: Key) throws -> AnyExporterConfiguration {
        switch self {
        case .rest:
            return AnyExporterConfiguration(try container.decode(RESTExporterConfiguration.self, forKey: key))
        case .grpc:
            return AnyExporterConfiguration(try container.decode(GRPCExporterConfiguration.self, forKey: key))
        }
    }
}

// TODO Exporter stuff

extension _ExporterConfiguration {
    /// The `DeltaIdentifier` of the Exporter.
    public static var deltaIdentifier: DeltaIdentifier {
        "\(type.rawValue)"
    }
}

extension AnyExporterConfiguration: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier {
        "\(type.rawValue)"
    }
}
