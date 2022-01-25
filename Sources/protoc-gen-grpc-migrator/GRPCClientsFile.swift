//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobufPluginLibrary

class GRPCClientsFile: SourceCodeRenderable {
    let protoFile: FileDescriptor
    let context: ProtoFileContext
    let migrationGuide: MigrationGuide

    var services: [String: GRPCService] = [:]

    init(_ file: FileDescriptor, context: ProtoFileContext, migrationGuide: MigrationGuide) {
        self.protoFile = file
        self.context = context
        self.migrationGuide = migrationGuide

        for service in protoFile.services {
            self.services[service.name] = GRPCService(service, locatedIn: self)
        }

        // TODO ensure endpoint changes are only considered for the first file!
        parseEndpointChanges()
    }

    var renderableContent: String {
        FileHeaderComment()

        Import(.foundation)
        Import("NIO")
        Import("GRPC")
        Import("\(context.namer.swiftProtobufModuleName)")

        for service in self.services.values.sorted(by: \.serviceName) {
            service
        }
    }

    private func parseEndpointChanges() {
        var addedEndpoints: [EndpointChange.AdditionChange] = []
        var updatedEndpoints: [EndpointChange.UpdateChange] = []
        var removedEndpoints: [EndpointChange.RemovalChange] = []

        for change in migrationGuide.endpointChanges {
            // we ignore idChange updates. Why? Because we always work with the older identifiers.
            // And for the client library identifiers should not be modified to maintain code compatibility.

            if let addition = change.modeledAdditionChange {
                addedEndpoints.append(addition)
            } else if let update = change.modeledUpdateChange {
                updatedEndpoints.append(update)
            } else if let removal = change.modeledRemovalChange {
                removedEndpoints.append(removal)
            }
        }

        for addedEndpoint in addedEndpoints {
            let endpoint = addedEndpoint.added
            let serviceName = endpoint.identifier(for: GRPCServiceName.self).rawValue

            if let existingService = self.services[serviceName] {
                existingService.addEndpoint(endpoint)
            } else {
                let service = GRPCService(named: serviceName, locatedIn: self)
                service.addEndpoint(endpoint)
                self.services[serviceName] = service
            }
        }

        for updatedEndpoint in updatedEndpoints {
            for service in services.values {
                service.handleEndpointUpdate(updatedEndpoint)
            }
        }

        for removedEndpoint in removedEndpoints {
            for service in services.values {
                service.handleEndpointRemoval(removedEndpoint)
            }
        }
    }
}
