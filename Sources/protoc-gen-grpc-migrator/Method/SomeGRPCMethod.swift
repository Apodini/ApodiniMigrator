//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

protocol SomeGRPCMethod {
    var methodName: String { get }
    var updatedMethodName: String? { get }

    var serviceName: String { get }
    var updatedServiceName: String? { get }

    var sourceCodeComments: String? { get }

    /// If true, this Method was removed in the latest version.
    var unavailable: Bool { get }
    /// Carrying ``EndpointIdentifierChange`` changes (e.g. serviceName or servicePath changes)
    var identifierChanges: [ElementIdentifierChange] { get }
    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)? { get }
    var responseChange: (
        from: TypeInformation,
        to: TypeInformation,
        backwardsMigration: Int,
        migrationWarning: String?
    )? { get }

    var methodPath: String { get }
    var updatedMethodPath: String? { get }

    var methodWrapperFunctionName: String { get }

    var streamingType: StreamingType { get }

    var inputMessageName: String { get }
    var outputMessageName: String { get }
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
        nil
    }

    var updatedServiceName: String? {
        nil
    }
    var updatedMethodPath: String? {
        let serviceName = updatedServiceName
        let methodName = updatedMethodName
        if serviceName == nil && methodName == nil {
            return nil
        }

        return "\(serviceName ?? self.serviceName)/\(methodName ?? self.methodName)"
    }

    var unavailable: Bool {
        false
    }

    var identifierChanges: [ElementIdentifierChange] {
        []
    }

    var communicationPatternChange: (from: CommunicationPattern, to: CommunicationPattern)? {
        nil
    }

    var responseChange: (from: TypeInformation, to: TypeInformation, backwardsMigration: Int, migrationWarning: String?)? {
        nil
    }

    var updatedOutputMessageName: String? {
        nil
    }
}
