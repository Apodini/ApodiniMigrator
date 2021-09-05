//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCompare

struct NetworkingMigrator {
    let networkingPath: Path
    let oldMetaData: MetaData
    let networkingChanges: [Change]
    
    func serverPath() -> String {
        var serverPath = oldMetaData.versionedServerPath
        for change in networkingChanges where change.element.target == NetworkingTarget.serverPath.rawValue {
            if let updateChange = change as? UpdateChange, case let .stringValue(newPath) = updateChange.to {
                serverPath = newPath
            }
        }
        return serverPath
    }
    
    func encoderConfiguration() -> EncoderConfiguration {
        var encoderConfiguration = oldMetaData.encoderConfiguration
        for change in networkingChanges where change.element.target == NetworkingTarget.encoderConfiguration.rawValue {
            if let updateChange = change as? UpdateChange, case let .element(anyCodable) = updateChange.to {
                encoderConfiguration = anyCodable.typed(EncoderConfiguration.self)
            }
        }
        return encoderConfiguration
    }
    
    func decoderConfiguration() -> DecoderConfiguration {
        var decoderConfiguration = oldMetaData.decoderConfiguration
        for change in networkingChanges where change.element.target == NetworkingTarget.decoderConfiguration.rawValue {
            if let updateChange = change as? UpdateChange, case let .element(anyCodable) = updateChange.to {
                decoderConfiguration = anyCodable.typed(DecoderConfiguration.self)
            }
        }
        return decoderConfiguration
    }
}
