//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// ``Change`` type which is related to the `ServiceInformation`
/// `.update` changes are encoded as ``ServiceInformationUpdateChange``.
public typealias ServiceInformationChange = Change<ServiceInformation>

extension ServiceInformation: ChangeableElement {
    public typealias Update = ServiceInformationUpdateChange
}

public enum ServiceInformationUpdateChange: Equatable {
    /// Defines an update to the service `Version`.
    case version(
        from: Version,
        to: Version
    )

    /// Defines an update to the `HTTPInformation` of the service.
    case http(
        from: HTTPInformation,
        to: HTTPInformation
    )

    /// Defines an update of the `ExporterConfiguration` of the service.
    case exporter(exporter: ExporterConfigurationChange)
}

// MARK: Codable
extension ServiceInformationUpdateChange: Codable {
    private enum EnumType: String, Codable {
        case version
        case http
        case exporter
    }

    private var type: EnumType {
        switch self {
        case .version:
            return .version
        case .http:
            return .http
        case .exporter:
            return .exporter
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case from
        case to

        case exporter
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(EnumType.self, forKey: .type)

        switch type {
        case .version:
            self = .version(
                from: try container.decode(Version.self, forKey: .from),
                to: try container.decode(Version.self, forKey: .to)
            )
        case .http:
            self = .http(
                from: try container.decode(HTTPInformation.self, forKey: .from),
                to: try container.decode(HTTPInformation.self, forKey: .to)
            )
        case .exporter:
            self = .exporter(exporter: try container.decode(ExporterConfigurationChange.self, forKey: .exporter))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)

        switch self {
        case let .version(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        case let .http(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        case let .exporter(exporter):
            try container.encode(exporter, forKey: .exporter)
        }
    }
}
