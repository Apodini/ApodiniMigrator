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
    private enum CodingKeys: String, CodingKey {
        case version
        case http
        case exporters
    }

    /// Version information of the running web service.
    public let version: Version

    /// Information about the exposed http endpoint
    public let http: HTTPInformation

    public var exporters: [ExporterConfiguration]

    public var configuredExporters: [ApodiniExporterType] {
        exporters.map { $0.type }
    }

    init(
        version: Version,
        http: HTTPInformation,
        exporters: [ExporterConfiguration]
    ) {
        self.version = version
        self.http = http
        self.exporters = exporters
    }

    init(
        version: Version,
        http: HTTPInformation,
        exporters: ExporterConfiguration...
    ) {
        self.init(version: version, http: http, exporters: exporters)
    }

    public func exporter<Configuration: ExporterConfiguration>(for type: Configuration.Type = Configuration.self) -> Configuration {
        guard let configuration = exporters.first(where: { $0 is Configuration }),
              let castedConfiguration = configuration as? Configuration else {
            fatalError("Failed to retrieve exporter from ServiceInformation: \(type)")
        }

        return castedConfiguration
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(version)
        hasher.combine(http)
        hasher.combine(configuredExporters) // TODO enough (out of oder?)?
    }

    public static func == (lhs: ServiceInformation, rhs: ServiceInformation) -> Bool {
        lhs.version == rhs.version
            && lhs.http == rhs.http
            && lhs.configuredExporters == rhs.configuredExporters // TODO enough? (TODO compare out of order!)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.version = container.decode(Version.self, forKey: .version)
        try self.http = container.decode(HTTPInformation.self, forKey: .http)
        self.exporters = []

        var exporterContainer = try container.nestedUnkeyedContainer(forKey: .exporters)
        while !exporterContainer.isAtEnd {
            if let httpConfiguration = try? exporterContainer.decode(RESTExporterConfiguration.self) {
                exporters.append(httpConfiguration)
            } else {
                throw APIDocument.CodingError.decodingUnsupportedExporterConfiguration(container: exporterContainer)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(http, forKey: .http)


        var exporterContainer = container.nestedUnkeyedContainer(forKey: .exporters)
        for exporter in exporters {
            if let httpExporter = exporter as? RESTExporterConfiguration {
                try exporterContainer.encode(httpExporter)
            } else {
                throw APIDocument.CodingError.encodingUnsupportedExporterConfiguration(configuration: exporter)
            }
        }
    }
}

extension ServiceInformation: DeltaIdentifiable {
    // there is only a single service information
    public static var deltaIdentifier: DeltaIdentifier = "SERVICE_INFO_ID"

    public var deltaIdentifier: DeltaIdentifier {
        Self.deltaIdentifier
    }
}
