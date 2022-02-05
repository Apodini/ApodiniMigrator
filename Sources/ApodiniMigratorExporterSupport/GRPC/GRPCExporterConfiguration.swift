//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OrderedCollections

public struct GRPCExporterConfiguration: ExporterConfiguration {
    public static var type: ApodiniExporterType {
        .grpc
    }

    public let packageName: String
    public let serviceName: String
    public let pathPrefix: String
    public let reflectionEnabled: Bool

    /// Identifiers of synthesized types (input and output type wrappers) aren't stored
    /// in the APIDocument along with the `TypeInformation` (as the don't exist).
    /// Therefore we transport them separately.
    /// Identified by the rawValue of the HandlerName (so result of `String(reflecting: MyHandler.self)`
    /// which is the value saved in `Endpoint/handlerName`).
    public var identifiersOfSynthesizedTypes: OrderedDictionary<String, EndpointSynthesizedTypes>

    public init(
        packageName: String,
        serviceName: String,
        pathPrefix: String,
        reflectionEnabled: Bool,
        identifiersOfSynthesizedTypes: OrderedDictionary<String, EndpointSynthesizedTypes> = [:]
    ) {
        self.packageName = packageName
        self.serviceName = serviceName
        self.pathPrefix = pathPrefix
        self.reflectionEnabled = reflectionEnabled
        self.identifiersOfSynthesizedTypes = identifiersOfSynthesizedTypes
    }
}

public struct TypeInformationIdentifiers: Codable, Hashable {
    public var identifiers: ElementIdentifierStorage
    public var childrenIdentifiers: OrderedDictionary<String, ElementIdentifierStorage>

    public init(
        identifiers: ElementIdentifierStorage = .init(),
        childrenIdentifiers: OrderedDictionary<String, ElementIdentifierStorage> = [:]
    ) {
        self.identifiers = identifiers
        self.childrenIdentifiers = childrenIdentifiers
    }
}

public struct EndpointSynthesizedTypes: Codable, Hashable {
    public var inputIdentifiers: TypeInformationIdentifiers?
    public var outputIdentifiers: TypeInformationIdentifiers?

    public init(inputIdentifiers: TypeInformationIdentifiers?, outputIdentifiers: TypeInformationIdentifiers?) {
        self.inputIdentifiers = inputIdentifiers
        self.outputIdentifiers = outputIdentifiers
    }
}
