//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Any conforming type, describes a configured exporter on a Apodini web service.
public protocol ExporterConfiguration: _ExporterConfiguration, Hashable {}

public protocol _ExporterConfiguration: Codable {
    /// The ``ApodiniExporterType`` of the configuration.
    static var type: ApodiniExporterType { get }

    /// A type erased `==` function. This method is implemented by default when conforming to `Equatable`.
    func compare(to exporter: _ExporterConfiguration) -> Bool

    /// A type erased `hash(into:)`. This method is implemented by default when conforming to `Hashable`.
    func anyHash(into hasher: inout Hasher)
}

extension _ExporterConfiguration {
    /// The ``ApodiniExporterType`` of the configuration.
    public var type: ApodiniExporterType {
        Self.type
    }

    func anyEncode<Key>(into container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws {
        try container.encode(self, forKey: key)
    }
}


public struct AnyExporterConfiguration: Hashable {
    private let exporter: _ExporterConfiguration

    public var type: ApodiniExporterType {
        exporter.type
    }

    public init(untyped exporter: _ExporterConfiguration) {
        self.exporter = exporter
    }

    public init<Exporter: ExporterConfiguration>(_ exporter: Exporter) {
        self.exporter = exporter
    }

    public func tryTyped<Exporter: ExporterConfiguration>(of exporter: Exporter.Type = Exporter.self) -> Exporter? {
        self.exporter as? Exporter
    }

    public func typed<Exporter: ExporterConfiguration>(of exporter: Exporter.Type = Exporter.self) -> Exporter {
        guard let castedExporter = self.exporter as? Exporter else {
            fatalError("Failed to cast exporter to \(Exporter.self): \(exporter)")
        }

        return castedExporter
    }

    public func anyEncode<Key>(into container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws {
        try exporter.anyEncode(into: &container, forKey: key)
    }

    public static func == (lhs: AnyExporterConfiguration, rhs: AnyExporterConfiguration) -> Bool {
        lhs.exporter.compare(to: rhs.exporter)
    }

    public func hash(into hasher: inout Hasher) {
        exporter.anyHash(into: &hasher)
    }
}

extension AnyExporterConfiguration: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ApodiniExporterType.self, forKey: .type)

        switch type {
        case .rest:
            try exporter = RESTExporterConfiguration(from: decoder)
        case .grpc:
            try exporter = GRPCExporterConfiguration(from: decoder)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(exporter.type, forKey: .type)
        try exporter.encode(to: encoder)
    }
}

extension ExporterConfiguration {
    /// Default type erased implementation for `Equatable`.
    public func compare(to exporter: _ExporterConfiguration) -> Bool {
        guard let casted = exporter as? Self else {
            fatalError("\(Swift.type(of: exporter)) cannot be casted to \(Self.self).")
        }

        return self == casted
    }

    /// Default type erased implementation for `Hashable`.
    public func anyHash(into hasher: inout Hasher) {
        self.hash(into: &hasher)
    }
}
