//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

public enum APIDocumentVersion: String, Codable {
    case v1 = "1.0.0"
    case v2 = "2.0.0"
}

/// A API document describing an Apodini Web Service.
public struct APIDocument: Value {
    /// Id of the document
    public let id: UUID // TODO how do we generate the Id (and persist it in API documents)
    /// Describes the version the ``Document`` was generate with
    public let documentVersion: APIDocumentVersion // TODO we don't really need this property STORED?
    /// Metadata
    public var serviceInformation: ServiceInformation
    /// Endpoints
    private var _endpoints: [Endpoint]
    public var endpoints: [Endpoint] {
        _endpoints // TODO best solution for dereferencing?
            .map {
                var endpoint = $0
                endpoint.dereference(in: types)
                return endpoint
            }
    }

    public var types: TypesStore

    public var models: [TypeInformation] {
        Array(types.values)
    }

    /*
    // TODO turn into property (and maybe split up into response and parameters)
    public func allModels() -> [TypeInformation] {
        // TODO we duplicate the TypeStore data structure!
        endpoints.reduce(into: Set<TypeInformation>()) { result, current in
                result.insert(current.response)
                current.parameters.forEach { parameter in
                    result.insert(parameter.typeInformation)
                }
            }
            .asArray
            .fileRenderableTypes()
            .sorted(by: \.typeName)
    }*/
    
    /// Name of the file, constructed as `api_{version}`
    public var fileName: String {
        "api_\(serviceInformation.version.string.replacingOccurrences(of: "_", with: ""))"
    }
    
    /// Initializes a new Apodini API document.
    public init(serviceInformation: ServiceInformation) {
        self.id = .init()
        self.documentVersion = .v2
        self.serviceInformation = serviceInformation
        self._endpoints = []
        self.types = TypesStore()
    }
    
    /// Adds a new endpoint
    public mutating func add(endpoint: Endpoint) {
        var endpoint = endpoint
        endpoint.reference(in: &types)
        _endpoints.append(endpoint)
    }

    public mutating func add<Configuration: ExporterConfiguration>(exporter: Configuration) {
        // TODO non generic func?
        serviceInformation.exporters.append(exporter)
    }
}

// MARK: Codable
extension APIDocument: Codable {
    public enum CodingError: Error {
        case unsupportedDocumentVersion(version: String)

        case decodingUnsupportedExporterConfiguration(container: UnkeyedDecodingContainer)
        case encodingUnsupportedExporterConfiguration(configuration: ExporterConfiguration)
    }

    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case id
        case documentVersion = "version"
        case serviceInformation = "service"
        case endpoints
        case types

        case legacyServiceInformation = "info"
        case legacyTypes = "components"
    }

    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let documentVersion: APIDocumentVersion
        do {
            try documentVersion = container.decodeIfPresent(APIDocumentVersion.self, forKey: .documentVersion) ?? .v1
        } catch {
            // failed to decode APIDocumentVersion, probably because its an unknown version!
            throw CodingError.unsupportedDocumentVersion(version: try container.decode(String.self, forKey: .documentVersion))
        }

        try id = container.decode(UUID.self, forKey: .id)

        switch documentVersion {
        case .v1:
            let legacyInformation = try container.decode(LegacyServiceInformation.self, forKey: .legacyServiceInformation)
            try self.serviceInformation = ServiceInformation(from: legacyInformation)

            let endpoints = try container.decode([LegacyEndpoint].self, forKey: .endpoints)
            self._endpoints = endpoints.map { Endpoint(from: $0) }

            try types = container.decode(TypesStore.self, forKey: .legacyTypes)
        case .v2:
            try serviceInformation = container.decode(ServiceInformation.self, forKey: .serviceInformation)
            try _endpoints = container.decode([Endpoint].self, forKey: .endpoints)
            try types = container.decode(TypesStore.self, forKey: .types)
        }

        self.documentVersion = .v2
    }

    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentVersion, forKey: .documentVersion)
        try container.encode(serviceInformation, forKey: .serviceInformation)
        try container.encode(_endpoints, forKey: .endpoints)
        try container.encode(types, forKey: .types)
    }
}
