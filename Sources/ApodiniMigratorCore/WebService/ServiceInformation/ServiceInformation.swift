//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// General Information about the web service.
public struct ServiceInformation: Value, Hashable {
    /// Version information of the running web service.
    public let version: Version

    /// Information about the exposed http endpoint
    public let http: HTTPInformation

    public var exporters: [ApodiniExporterType: AnyExporterConfiguration]

    public var configuredExporters: Dictionary<ApodiniExporterType, AnyExporterConfiguration>.Keys {
        exporters.keys
    }

    init(
        version: Version,
        http: HTTPInformation,
        exporters: [_ExporterConfiguration]
    ) {
        self.version = version
        self.http = http
        self.exporters = [:]

        for exporter in exporters {
            self.exporters[exporter.type] = AnyExporterConfiguration(untyped: exporter)
        }
    }

    init(
        version: Version,
        http: HTTPInformation,
        exporters: _ExporterConfiguration...
    ) {
        self.init(version: version, http: http, exporters: exporters)
    }

    @discardableResult
    public mutating func add<Exporter: ExporterConfiguration>(exporter: Exporter) -> Self {
        exporters[Exporter.type] = AnyExporterConfiguration(exporter)
        return self
    }

    public func exporter<Exporter: ExporterConfiguration>(for type: Exporter.Type = Exporter.self) -> Exporter {
        guard let exporter = exporters[Exporter.type] else {
            fatalError("Failed to retrieve exporter from ServiceInformation: \(type)")
        }

        return exporter.typed()
    }

    public func exporterIfPresent<Exporter: ExporterConfiguration>(for type: Exporter.Type = Exporter.self) -> Exporter? {
        guard let exporter = exporters[Exporter.type] else {
            return nil
        }

        return exporter.typed()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(version)
        hasher.combine(http)
        hasher.combine(exporters)
    }

    public static func == (lhs: ServiceInformation, rhs: ServiceInformation) -> Bool {
        lhs.version == rhs.version
            && lhs.http == rhs.http
            && lhs.exporters == rhs.exporters
    }
}

extension ServiceInformation: DeltaIdentifiable {
    // there is only a single service information
    public static var deltaIdentifier: DeltaIdentifier = "SERVICE_INFO_ID"

    public var deltaIdentifier: DeltaIdentifier {
        Self.deltaIdentifier
    }
}

extension ServiceInformation: Codable {
    private enum CodingKeys: String, CodingKey {
        case version
        case http
        case exporters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.version = container.decode(Version.self, forKey: .version)
        try self.http = container.decode(HTTPInformation.self, forKey: .http)
        self.exporters = [:]

        let exporterContainer = try container.nestedContainer(keyedBy: ApodiniExporterType.self, forKey: .exporters)
        for type in ApodiniExporterType.allCases {
            var exporter: AnyExporterConfiguration?
            do {
                exporter = try type.anyDecode(from: exporterContainer, forKey: type)
            } catch DecodingError.keyNotFound {
                exporter = nil
            }

            if let exporter = exporter {
                self.exporters[type] = exporter
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(http, forKey: .http)

        var exporterContainer = container.nestedContainer(keyedBy: ApodiniExporterType.self, forKey: .exporters)
        for (key, exporter) in exporters {
            try exporter.anyEncode(into: &exporterContainer, forKey: key)
        }
    }
}
