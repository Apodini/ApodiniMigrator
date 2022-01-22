//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit
import ApodiniMigrator

struct ProtocGenerator: LibraryNode {
    enum HandleError: Error {
        case missingProtocBinary(message: String)
        case missingGRPCMigratorPlugin(message: String)
    }

    let pluginName: String
    let protoPath: String
    let protoFile: String
    let options: [String: String]
    let environment: [String: String]? // swiftlint:disable:this discouraged_optional_collection

    init(
        pluginName: String,
        protoPath: String,
        protoFile: String,
        options: [String: String],
        environment: [String: String]? = nil // swiftlint:disable:this discouraged_optional_collection
    ) {
        self.pluginName = pluginName
        self.protoPath = protoPath
        self.protoFile = protoFile
        self.options = options
        self.environment = environment
    }

    func handle(at path: Path, with context: MigrationContext) throws {
        guard let protocBinary = findExecutable(named: "protoc") else {
            throw HandleError.missingProtocBinary(message: "It seems like the `protoc` compiler isn't installed!")
        }

        guard findExecutable(named: "protoc-gen-\(pluginName)") != nil else {
            throw HandleError.missingGRPCMigratorPlugin(message: "It seems that the `protoc-gen-\(pluginName)` is not installed.")
        }

        var args: [String] = [
            "--\(pluginName)_out=\(path.description)",
            "--proto_path=\(protoPath)"
        ]

        if !options.isEmpty {
            args.append("--\(pluginName)_opt=\(options.map { "\($0)=\($1)" }.joined(separator: ","))")
        }

        args.append(protoFile)

        try shell(
            executableURL: protocBinary,
            args,
            environment: environment
        )
    }
}
