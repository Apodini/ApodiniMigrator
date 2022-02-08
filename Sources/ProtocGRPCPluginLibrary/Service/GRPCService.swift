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
    unowned let file: GRPCClientsFile
    let context: ProtoFileContext

    let serviceName: String
    private let serviceSourceComments: String?

    private var methods: [GRPCMethod] = []

    var protobufNamer: SwiftProtobufNamer {
        context.namer
    }
    
    var updatedPackageName: String {
        file.migration.rhsExporterConfiguration.packageName
    }

    var servicePath: String {
        if !updatedPackageName.isEmpty {
            return updatedPackageName + "." + serviceName
        } else {
            return serviceName
        }
    }

    init(_ service: ServiceDescriptor, locatedIn file: GRPCClientsFile) {
        self.file = file
        self.context = file.context
        self.serviceName = service.name
        self.methods = []

        self.serviceSourceComments = service.protoSourceComments()

        for method in service.methods {
            self.methods.append(GRPCMethod(ProtoGRPCMethod(method, locatedIn: self), context: context))
        }
    }

    init(named serviceName: String, locatedIn file: GRPCClientsFile) {
        self.file = file
        self.context = file.context
        self.serviceName = serviceName
        self.methods = []
        self.serviceSourceComments = nil
    }

    func addEndpoint(_ endpoint: Endpoint) {
        let method = ApodiniGrpcMethod(endpoint, context: context, migration: file.migration)
        precondition(
            !self.methods.contains(where: { $0.methodName == method.methodName }),
            "Added endpoint collides with existing method \(serviceName).\(method.methodName)"
        )

        self.methods.append(GRPCMethod(method, context: context))
    }

    func handleEndpointUpdate(_ update: EndpointChange.UpdateChange) {
        methods
            .filter { $0.deltaIdentifier == update.id }
            .forEach { $0.registerUpdateChange(update) }
    }

    func handleEndpointRemoval(_ removal: EndpointChange.RemovalChange) {
        methods
            .filter { $0.deltaIdentifier == removal.id }
            .forEach { $0.registerRemovalChange(removal) }
    }

    var renderableContent: String {
        ""
        if var comments = serviceSourceComments, !comments.isEmpty {
            _ = comments.removeLast() // removing last trailing "\n"
            comments
        }

        "\(context.options.visibility) struct \(serviceName)AsyncClient: GRPCClient {"
        Indent {
            "\(context.options.visibility) var serviceName: String {"
            Indent("\"\(servicePath)\"")
            """
            }

            \(context.options.visibility) var channel: GRPCChannel
            \(context.options.visibility) var defaultCallOptions: CallOptions
            """

            "\(context.options.visibility) init("
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
            for method in methods.sorted(by: \.methodName) {
                method
            }
        }
        "}"
    }
}
