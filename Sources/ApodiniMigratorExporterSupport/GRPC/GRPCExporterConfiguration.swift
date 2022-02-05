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
    public var identifiersOfSynthesizedTypes: [String: EndpointSynthesizedTypes]

    public init(
        packageName: String,
        serviceName: String,
        pathPrefix: String,
        reflectionEnabled: Bool,
        identifiersOfSynthesizedTypes: [String: EndpointSynthesizedTypes] = [:]
    ) {
        self.packageName = packageName
        self.serviceName = serviceName
        self.pathPrefix = pathPrefix
        self.reflectionEnabled = reflectionEnabled
        self.identifiersOfSynthesizedTypes = identifiersOfSynthesizedTypes
    }

    public static func == (lhs: GRPCExporterConfiguration, rhs: GRPCExporterConfiguration) -> Bool {
        lhs.packageName == rhs.packageName
            && lhs.serviceName == rhs.serviceName
            && lhs.pathPrefix == rhs.pathPrefix
            && lhs.reflectionEnabled == rhs.reflectionEnabled
            && [String: EndpointSynthesizedTypes].compareOrdered(lhs: lhs.identifiersOfSynthesizedTypes, rhs: rhs.identifiersOfSynthesizedTypes)
    }
}

public struct TypeInformationIdentifiers: Codable, Hashable {
    public var identifiers: ElementIdentifierStorage
    public var childrenIdentifiers: [String: ElementIdentifierStorage]

    public init(
        identifiers: ElementIdentifierStorage = .init(),
        childrenIdentifiers: [String: ElementIdentifierStorage] = [:]
    ) {
        self.identifiers = identifiers
        self.childrenIdentifiers = childrenIdentifiers
    }

    public static func == (lhs: TypeInformationIdentifiers, rhs: TypeInformationIdentifiers) -> Bool {
        guard lhs.identifiers == rhs.identifiers else {
            return false
        }

        return lhs.identifiers == rhs.identifiers
            && [String: ElementIdentifierStorage].compareOrdered(lhs: lhs.childrenIdentifiers, rhs: rhs.childrenIdentifiers)
    }
}

public struct EndpointSynthesizedTypes: Codable, Hashable {
    public var inputIdentifiers: TypeInformationIdentifiers?
    public var outputIdentifiers: TypeInformationIdentifiers?

    public init(
        inputIdentifiers: TypeInformationIdentifiers? = nil,
        outputIdentifiers: TypeInformationIdentifiers? = nil
    ) {
        self.inputIdentifiers = inputIdentifiers
        self.outputIdentifiers = outputIdentifiers
    }
}

fileprivate extension Dictionary where Key: Comparable, Value: Equatable {
    static func compareOrdered(lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        var lhsDictionary: OrderedDictionary<Key, Value> = lhs
            .reduce(into: [:]) { result, element in
                result[element.key] = element.value
            }
        var rhsDictionary: OrderedDictionary<Key, Value> = rhs
            .reduce(into: [:]) { result, element in
                result[element.key] = element.value
            }

        lhsDictionary.sort()
        rhsDictionary.sort()

        return lhsDictionary == rhsDictionary
    }
}
