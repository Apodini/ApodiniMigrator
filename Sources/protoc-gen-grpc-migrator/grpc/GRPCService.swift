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
    private unowned let file: GRPCClientFile

    private let service: ServiceDescriptor
    private var methods: [GRPCMethod]

    var protobufNamer: SwiftProtobufNamer {
        file.protobufNamer
    }

    var servicePath: String {
        if !file.protoFile.package.isEmpty {
            return file.protoFile.package + "." + service.name
        } else {
            return service.name
        }
    }

    init(_ service: ServiceDescriptor, locatedIn file: GRPCClientFile) {
        self.file = file
        self.service = service
        self.methods = []

        for method in service.methods {
            self.methods.append(GRPCMethod(method, locatedIn: self))
        }
    }

    var renderableContent: String {
        // TODO do we need #if directovies (>= 5.5 and _Concurrency)? and @available?

        var comments = service.protoSourceComments() // TODO we can control to remove the ///
        comments.removeLast()
        comments
        // TODO any other comments places?

        // TODO interceptor protocol?

        // TODO visibilit + service name!!
        "protocol \(service.name)AsyncClientProtocol: GRPCClient {"
        Indent {
            "var serviceName: String { get }"
            // TODO "var interceptors: "

            for method in methods {
                EmptyLine()
                method.clientProtocolSignature
            }
        }
        "}"

        EmptyLine()

        "extension \(service.name)AsyncClientProtocol {"
        Indent {
            "var serviceName: String {"
            Indent("\"\(servicePath)\"")
            "}"
            // TODO interceptors

            for method in methods {
                EmptyLine()

                method.clientProtocolExtensionFunction
            }
        }
        "}"

        EmptyLine()

        // TODO protocol extension with the "safe" wrapper stuff? huh?

        // TODO visibilit + service name!!
        "struct \(service.name)AsyncClient: \(service.name)AsyncClientProtocol {"
        Indent {
            """
            var channel: GRPCChannel
            var defaultCallOptions: CallOptions
            """
            // TODO interceptors

            "init("
            Indent {
                """
                channel: GRPCChannel,
                defaultCallOptions: CallOptions = CallOptions()
                """
                // TODO interceptors
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

        "extension \(service.name)AsyncClient {"
        Indent {
            for method in methods {
                method.clientProtocolExtensionSafeWrappers
            }
        }
        "}"
    }
}
