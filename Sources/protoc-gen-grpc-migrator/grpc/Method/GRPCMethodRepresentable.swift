//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

protocol GRPCMethodRepresentable {
    var methodName: String { get }
    var updatedMethodName: String? { get }

    var serviceName: String { get }
    var updatedServiceName: String? { get }

    var sourceCodeComments: String? { get }

    /// If true, this Method was removed in the latest version.
    var unavailable: Bool { get }
    var identifierChanges: [EndpointIdentifierChange] { get } // TODO serviceName and servicePath!
    var communicationPatternChange: (from: CommunicationalPattern, to: CommunicationalPattern)? { get }
    var responseChangeChange: (
        from: TypeInformation,
        to: TypeInformation,
        backwardsMigration: Int,
        migrationWarning: String?
    )? { get }
    // TODO parameterChange?

    var methodPath: String { get }
    var updatedMethodPath: String? { get }

    var methodWrapperFunctionName: String { get }

    var streamingType: StreamingType { get }

    var inputMessageName: String { get }
    var outputMessageName: String { get }
}

extension GRPCMethodRepresentable {
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

    var identifierChanges: [EndpointIdentifierChange] {
        []
    }

    var communicationPatternChange: (from: CommunicationalPattern, to: CommunicationalPattern)? {
        nil
    }

    var responseChangeChange: (from: TypeInformation, to: TypeInformation, backwardsMigration: Int, migrationWarning: String?)? {
        nil
    }
}

extension GRPCMethodRepresentable {
    // TODO placement
    internal func sanitize(fieldName string: String) -> String {
        if quotableFieldNames.contains(string) {
            return "`\(string)`"
        }
        return string
    }
}
