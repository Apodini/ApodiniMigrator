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
    /// See `protoc` `--plugin=EXECUTABLE` option.
    let manualPluginPaths: [String: String]
    let environment: [String: String]? // swiftlint:disable:this discouraged_optional_collection

    init(
        pluginName: String,
        protoPath: String,
        protoFile: String,
        options: [String: String],
        manualPluginPaths: [String: String]? = nil, // swiftlint:disable:this discouraged_optional_collection
        environment: [String: String]? = nil // swiftlint:disable:this discouraged_optional_collection
    ) {
        self.pluginName = pluginName
        self.protoPath = protoPath
        self.protoFile = protoFile
        self.options = options
        self.manualPluginPaths = manualPluginPaths ?? [:]
        self.environment = environment
    }

    func handle(at path: Path, with context: MigrationContext) throws {
        guard let protocBinary = findExecutable(named: "protoc") else {
            throw HandleError.missingProtocBinary(message: "It seems like the `protoc` compiler isn't installed!")
        }

        let executableName = "protoc-gen-\(pluginName)"
        var manualPluginPaths = manualPluginPaths

        if manualPluginPaths[executableName] == nil {
            if findExecutable(named: executableName) == nil {
                guard let localPlugin = tryToLocateLocalProtocPlugin(name: executableName) else {
                    throw HandleError.missingGRPCMigratorPlugin(message: "It seems that the `protoc-gen-\(pluginName)` is not installed.")
                }

                manualPluginPaths[executableName] = localPlugin
            }
        }

        var args: [String] = [
            "--\(pluginName)_out=\(path.description)",
            "--proto_path=\(protoPath)"
        ]

        if !options.isEmpty {
            args.append("--\(pluginName)_opt=\(options.map { "\($0)=\($1)" }.joined(separator: ","))")
        }

        if !manualPluginPaths.isEmpty {
            let option = manualPluginPaths
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ",")
            args.append("--plugin=\(option)")
        }

        args.append(protoFile)

        try shell(
            executableURL: protocBinary,
            args,
            environment: environment
        )
    }

    private func tryToLocateLocalProtocPlugin(name: String) -> String? {
        let path = Path(stringLiteral: Bundle.main.bundlePath) + name
        guard path.exists else {
            print("""
                  Tried to locate \(name) plugin in local dev environment, but couldn't find it (potential bundle locations: \(Bundle.allBundles.map { $0.bundlePath })). \
                  Please add the `\(name)` to your PATH variable.
                  """)
            return nil
        }

        return path.string
    }
}
