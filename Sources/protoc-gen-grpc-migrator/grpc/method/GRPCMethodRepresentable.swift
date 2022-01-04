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
    var sourceCodeComments: String? { get }

    /// If true, this Method was removed in the latest version.
    var unavailable: Bool { get }

    var methodPath: String { get }

    var methodMakeFunctionName: String { get }

    var methodWrapperFunctionName: String { get }

    var streamingType: StreamingType { get }

    var callType: String { get }
    var callTypeWithoutPrefix: String { get }

    var inputMessageName: String { get }
    var outputMessageName: String { get }
}

extension GRPCMethodRepresentable {
    var methodMakeFunctionName: String {
        var name = methodName
        name = name.prefix(1).uppercased() + name.dropFirst()
        return sanitize(fieldName: name)
    }

    var methodWrapperFunctionName: String {
        var name = methodName
        name = name.prefix(1).lowercased() + name.dropFirst()
        return sanitize(fieldName: name)
    }

    var callType: String {
        // TODO make this part of the streamingType overload
        Types.call(for: streamingType)
    }
    var callTypeWithoutPrefix: String {
        Types.call(for: streamingType, withGRPCPrefix: false)
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
