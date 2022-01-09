//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary

struct PluginOptions {
    enum ParserError: Error {
        case unknownParameter(key: String)
        case invalidParameterValue(name: String, value: String)
        case wrappedError(message: String, error: Error)
        case missingParameter(parameter: String)
    }

    enum Visibility: String {
        case `internal` = "Internal"
        case `public` = "Public"

        var sourceModifier: String {
            rawValue.lowercased()
        }
    }

    enum FileNaming: String {
        case FullPath
        case PathToUnderscores
        case DropPath
    }

    private(set) var documentPath: String?
    private(set) var migrationGuidePath: String?

    private(set) var visibility: Visibility = .internal
    private(set) var keepMethodCasing = false
    private(set) var protoToModuleMappings = ProtoFileToModuleMappings()
    private(set) var fileNaming = FileNaming.FullPath

    init(parameter: String) throws {
        for (key, value) in Self.parseParameterString(parameter) {
            switch key {
            case "APIDocument":
                self.documentPath = value
                // TODO path validation?
            case "MigrationGuide":
                self.migrationGuidePath = value
                // TODO path validation?

            case "Visibility":
                if let value = Visibility(rawValue: value) {
                    self.visibility = value
                } else {
                    throw ParserError.invalidParameterValue(name: key, value: value)
                }

            case "KeepMethodCasing":
                if let value = Bool(value) {
                    self.keepMethodCasing = value
                } else {
                    throw ParserError.invalidParameterValue(name: key, value: value)
                }

            case "ProtoPathModuleMappings":
                if !value.isEmpty {
                    do {
                        try self.protoToModuleMappings = ProtoFileToModuleMappings(path: value)
                    } catch let e {
                        throw ParserError.wrappedError(
                            message: "Parameter 'ProtoPathModuleMappings=\(value)'",
                            error: e
                        )
                    }
                }

            case "FileNaming":
                if let value = FileNaming(rawValue: value) {
                    self.fileNaming = value
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
