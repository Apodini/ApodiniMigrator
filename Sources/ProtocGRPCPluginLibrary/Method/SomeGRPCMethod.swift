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

protocol SomeGRPCMethod: AnyObject {
    var deltaIdentifier: DeltaIdentifier { get }

    var migration: MigrationContext { get }
    var namer: SwiftProtobufNamer { get }

    var updatedPackageName: String { get }
    var serviceName: String { get }
    var methodName: String { get }

    var sourceCodeComments: String? { get }

    /// If true, this Method was removed in the latest version.
    var unavailable: Bool { get set }
    /// Carrying ``EndpointIdentifierChange`` changes (e.g. serviceName or servicePath changes)
    var identifierChanges: [ElementIdentifierChange] { get set }
    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)? { get set }
    var parameterChange: (
        from: TypeInformation,
        to: TypeInformation,
        forwardMigration: Int,
        conversionWarning: String?
    )? { get set }
    var responseChange: (
        from: TypeInformation,
        to: TypeInformation,
        backwardsMigration: Int,
        migrationWarning: String?
    )? { get set }

    var methodPath: String { get }

    var methodWrapperFunctionName: String { get }

    var streamingType: StreamingType { get }

    var inputMessageName: String { get }
    var outputMessageName: String { get }
    var updatedInputMessageName: String? { get }
    var updatedOutputMessageName: String? { get }
}

extension SomeGRPCMethod {
    var methodWrapperFunctionName: String {
        var name = methodName
        name = name.prefix(1).lowercased() + name.dropFirst()
        return sanitize(fieldName: name)
    }

    var methodPath: String {
        "\(serviceName)/\(methodName)"
    }

    var updatedMethodName: String? {
        for change in identifierChanges {
            // we ignore addition and removal change (assumption is, as long as there is a grpc
            // exporter, all endpoints have service name and rpc method identifiers!)
            guard change.id.rawValue == GRPCMethodName.identifierType,
                  let update = change.modeledUpdateChange else {
                continue
            }

            precondition(update.updated.from.value == methodName)
            return update.updated.to.value
        }

        return nil
    }

    var updatedServiceName: String? {
        for change in identifierChanges {
            // we ignore addition and removal change (assumption is, as long as there is a grpc
            // exporter, all endpoints have service name and rpc method identifiers!)
            guard change.id.rawValue == GRPCServiceName.identifierType,
                  let update = change.modeledUpdateChange else {
                continue
            }

            precondition(update.updated.from.value == serviceName)
            return update.updated.to.value
        }

        return nil
    }

    var updatedMethodPath: String {
        let packageName = updatedPackageName
        let serviceName = updatedServiceName ?? serviceName
        let methodName = updatedMethodName ?? methodName
        
        let servicePath: String
        if !packageName.isEmpty {
            servicePath = packageName + "." + serviceName
        } else {
            servicePath = serviceName
        }

        return "/\(servicePath)/\(methodName)"
    }

    var updatedInputMessageName: String? {
        guard let change = parameterChange else {
            return nil
        }

        return change.to.swiftType(namer: namer)
    }

    var updatedOutputMessageName: String? {
        guard let change = responseChange else {
            return nil
        }

        return change.to.swiftType(namer: namer)
    }
}
