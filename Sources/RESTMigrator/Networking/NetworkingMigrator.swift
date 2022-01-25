//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCompare

struct NetworkingMigrator {
    let baseServiceInformation: ServiceInformation
    let serviceChanges: [ServiceInformationChange]

    private var exporterConfiguration: RESTExporterConfiguration {
        baseServiceInformation.exporter()
    }

    func serverPath() -> String {
        var serverPath = baseServiceInformation.http.description

        var rootPath = baseServiceInformation.exporter(for: RESTExporterConfiguration.self)
            .rootPath

        for change in serviceChanges {
            if let update = change.modeledUpdateChange {
                if case let .http(_, to) = update.updated {
                    serverPath = to.description
                } else if case let .exporter(exporter) = update.updated,
                    let updatedExporter = exporter.modeledUpdateChange, // we already ensured exporter isn't removed in RESTMigrator initializer
                    updatedExporter.updated.to.type == .rest {
                    rootPath = updatedExporter.updated.to.typed(of: RESTExporterConfiguration.self)
                        .rootPath
                }
            }
        }

        if let rootPath = rootPath {
            serverPath += "/" + rootPath
        }

        return serverPath
    }
    
    func encoderConfiguration() -> EncoderConfiguration {
        var encoderConfiguration = exporterConfiguration.encoderConfiguration

        for change in serviceChanges {
            if let update = change.modeledUpdateChange,
               case let .exporter(exporter) = update.updated,
               let exporterUpdate = exporter.modeledUpdateChange,
               let exporter = exporterUpdate.updated.to.tryTyped(of: RESTExporterConfiguration.self) {
                encoderConfiguration = exporter.encoderConfiguration
            }
        }

        return encoderConfiguration
    }
    
    func decoderConfiguration() -> DecoderConfiguration {
        var decoderConfiguration = exporterConfiguration.decoderConfiguration

        for change in serviceChanges {
            if let update = change.modeledUpdateChange,
               case let .exporter(exporter) = update.updated,
               let exporterUpdate = exporter.modeledUpdateChange,
               let exporter = exporterUpdate.updated.to.tryTyped(of: RESTExporterConfiguration.self) {
                decoderConfiguration = exporter.decoderConfiguration
            }
        }

        return decoderConfiguration
    }
}
