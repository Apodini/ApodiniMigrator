//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary
import PathKit

/// Plugin options for a ``ProtocPlugin``.
public struct PluginOptions {
    enum ParserError: Error {
        case unknownParameter(key: String)
        case invalidParameterValue(name: String, value: String)
        case wrappedError(message: String, error: Error)
        case missingParameter(parameter: String)
    }

    enum Visibility: String, CustomStringConvertible {
        case `internal` = "Internal"
        case `public` = "Public"

        var description: String {
            rawValue.lowercased()
        }
    }

    private(set) var documentPath: String?
    private(set) var migrationGuidePath: String?

    private(set) var visibility: Visibility = .internal

    /// Create a new `PluginOptions` instance from a rawValue string. Passed by protoc.
    public init(parameter: String) throws { // swiftlint:disable:this cyclomatic_complexity
        for (key, value) in Self.parseParameterString(parameter) {
            switch key {
            case "APIDocument":
                self.documentPath = value
                precondition(Path(value).exists, "APIDocument path doesn't exist at: \(value)")
            case "MigrationGuide":
                if !value.isEmpty {
                    self.migrationGuidePath = value
                    precondition(Path(value).exists, "MigrationGuide path doesn't exist: \(value)")
                }
            case "Visibility":
                if let value = Visibility(rawValue: value) {
                    self.visibility = value
                } else {
                    throw ParserError.invalidParameterValue(name: key, value: value)
                }
            default:
                throw ParserError.unknownParameter(key: key)
            }
        }

        if documentPath == nil {
            throw ParserError.missingParameter(parameter: "APIDocument")
        }
    }

    static func parseParameterString(_ string: String) -> [(key: String, value: String)] {
        guard !string.isEmpty else {
            return []
        }

        let parts = string.components(separatedBy: ",")

        return parts.map { string in
            guard let index = string.range(of: "=")?.lowerBound else {
                return (string, "")
            }

            let key = string[..<index]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let value = string[string.index(after: index)...]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return (key: key, value: value)
        }
    }
}
