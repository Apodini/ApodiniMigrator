//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary
import ApodiniMigrator

class GRPCService: SourceCodeRenderable {
    // TODO interceptors?
    private unowned let file: GRPCClientsFile

    let serviceName: String
    private let serviceSourceComments: String? // TODO needed?

    private var methods: [GRPCMethod]
    private var addedEndpoints: [String: Endpoint] = [:]

    var protobufNamer: SwiftProtobufNamer {
        file.protobufNamer
    }

    var servicePath: String {
        if !file.protoFile.package.isEmpty {
            return file.protoFile.package + "." + serviceName
        } else {
            return serviceName
        }
    }

    init(_ service: ServiceDescriptor, locatedIn file: GRPCClientsFile) {
        self.file = file
        self.serviceName = service.name
        self.methods = []

        self.serviceSourceComments = service.protoSourceComments()

        for method in service.methods {
            self.methods.append(GRPCMethod(method, locatedIn: self))
        }
    }

    init(named serviceName: String, locatedIn file: GRPCClientsFile) {
        self.file = file
        self.serviceName = serviceName
        self.methods = []
        self.serviceSourceComments = nil
    }

    func addEndpoint(_ endpoint: Endpoint) {
        let methodName = endpoint.identifier(for: GRPCMethodName.self).rawValue
        precondition(!self.methods.contains(where: { $0.methodName == methodName }), "Added endpoint collides with existing method \(serviceName).\(methodName)")
        precondition(self.addedEndpoints[methodName] == nil, "Added endpoint collides with added endpoint \(serviceName).\(methodName)")

        self.addedEndpoints[methodName] = endpoint
    }

    func handleEndpointUpdate(_ update: EndpointChange.UpdateChange) {
        methods
            .filter { $0.apodiniIdentifiers.deltaIdentifier == update.id }
            .forEach { $0.registerUpdateChange(update) }
    }

    func handleEndpointRemoval(_ removal: EndpointChange.RemovalChange) {
        methods
            .filter { $0.apodiniIdentifiers.deltaIdentifier == removal.id }
            .forEach { $0.unavailable = true }
    }

    var renderableContent: String {
        var joinedMethods: [GRPCMethodRenderable & GRPCMethodRepresentable] = methods
        joinedMethods.append(contentsOf: Array(addedEndpoints.values))
        joinedMethods.sorted(by: \.methodName)

        // TODO we don't actually need any SERVICE comments(?)
        if var comments = self.serviceSourceComments {
            comments.removeLast()
            comments
        }

        // TODO visibilit + service name!!
        "public struct \(serviceName)AsyncClient: \(serviceName)AsyncClientProtocol {"
        Indent {
            "var serviceName: String {"
            Indent("\"\(servicePath)\"")
            """
            }

            var channel: GRPCChannel
            var defaultCallOptions: CallOptions
            """

            "init("
            Indent {
                """
                channel: GRPCChannel,
                defaultCallOptions: CallOptions = CallOptions()
                """
            }
            ") {"
            Indent {
                """
                self.channel = channel
                self.defaultCallOptions = defaultCallOptions
                """
            }
            "}"
        }
        "}"

        EmptyLine()

        "extension \(serviceName)AsyncClient {"
        Indent {
            for method in joinedMethods {
                method.clientProtocolExtensionSafeWrappers
            }
        }
        "}"
    }
}
