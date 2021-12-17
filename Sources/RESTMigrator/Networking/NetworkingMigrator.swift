//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCompare

private extension HTTPInformation {
    var urlFormatted: String {
        // TODO assuming http for now!
        "http://\(description)"
    }
}

struct NetworkingMigrator {
    let baseServiceInformation: ServiceInformation
    let serviceChanges: [ServiceInformationChange]

    private var exporterConfiguration: RESTExporterConfiguration {
        baseServiceInformation.exporter()
    }

    func serverPath() -> String {
        var serverPath = baseServiceInformation.http.urlFormatted

        for change in serviceChanges {
            if case let .update(_, updated, _, _) = change,
               case let .http(from, to) = updated {
                serverPath = to.urlFormatted
            }
        }

        return serverPath
    }
    
    func encoderConfiguration() -> EncoderConfiguration {
        var encoderConfiguration = exporterConfiguration.encoderConfiguration

        /*
         TODO support exporter config changes!
        for change in networkingChanges where change.element.target == NetworkingTarget.encoderConfiguration.rawValue {
            if let updateChange = change as? UpdateChange, case let .element(anyCodable) = updateChange.to {
                encoderConfiguration = anyCodable.typed(EncoderConfiguration.self)
            }
        }
         */
        return encoderConfiguration
    }
    
    func decoderConfiguration() -> DecoderConfiguration {
        var decoderConfiguration = exporterConfiguration.decoderConfiguration

        /*
         TODO support exporter config changes
        for change in networkingChanges where change.element.target == NetworkingTarget.decoderConfiguration.rawValue {
            if let updateChange = change as? UpdateChange, case let .element(anyCodable) = updateChange.to {
                decoderConfiguration = anyCodable.typed(DecoderConfiguration.self)
            }
        }
         */
        return decoderConfiguration
    }
}
