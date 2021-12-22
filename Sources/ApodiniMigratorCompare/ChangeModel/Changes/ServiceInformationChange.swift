//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public typealias ServiceInformationChange = ChangeEnum<ServiceInformationChangeDeclaration>

public struct ServiceInformationChangeDeclaration: ChangeDeclaration {
    public typealias Element = ServiceInformation
    public typealias Update = ServiceInformationUpdateChange
}

public enum ServiceInformationUpdateChange: Codable {
    case version(
        from: Version,
        to: Version
    )

    case http(
        from: HTTPInformation,
        to: HTTPInformation
    )

    case exporter(
        exporter: ApodiniExporterType,
        from: ExporterConfiguration, // TODO more granular? (e.g. encode/decode configuration?)
        to: ExporterConfiguration
    )

    public init(from decoder: Decoder) throws {
        // TODO decodable
        fatalError("ServiceInformationUpdateChange(from:) isn't implemented yet")
    }

    public func encode(to encoder: Encoder) throws {
        //TODO encodable
        fatalError("ServiceInformationUpdateChange.encode(to:) isn't implemented yet")
    }
}
