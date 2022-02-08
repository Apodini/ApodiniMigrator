//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser
import SwiftProtobufPluginLibrary
import ProtocGRPCPluginLibrary
import PathKit

@main
struct ProtocPluginBootstrap: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Protoc Plugin Boostrap - Protoc plugin for the grpc client library migrator"
    )

    @Argument(completion: .directory)
    var path: String = ""

    func run() throws {
        let requestData: Data

        if !path.isEmpty { // for debug purposes, file can be supplied by cli argument
            let typedPath = Path(path).absolute()
            print("Proto request was provided by command line argument: \(typedPath)")
            guard typedPath.exists else {
                fatalError("Desired proto file doesn't exist at \(typedPath)")
            }
            try requestData = Data(contentsOf: URL(fileURLWithPath: typedPath.description))
        } else {
            guard let stdInData = try FileHandle.standardInput.readToEnd() else {
                fatalError("Failed to read from stdin!")
            }
            requestData = stdInData

            if let debugDumpPath = ProcessInfo.processInfo.environment["PROTOC_GEN_GRPC_DUMP"],
               !debugDumpPath.isEmpty {
                let dumpURL = URL(fileURLWithPath: Path(debugDumpPath).absolute().description)
                do {
                    try requestData.write(to: dumpURL)
                } catch {
                    // swiftlint:disable:next force_unwrapping
                    FileHandle.standardError.write("Failed to write PROTOC_GEN_GRPC_DUMP to \(debugDumpPath): \(error)".data(using: .utf8)!)
                }
            }
        }

        let request = try Google_Protobuf_Compiler_CodeGeneratorRequest(serializedData: requestData)

        let options = try PluginOptions(parameter: request.parameter)

        var plugin = try ProtocPlugin(request: request, options: options)

        try plugin.generate()

        let response = try plugin.response.serializedData()

        if !path.isEmpty {
            print(">>> Would successfully write contents of response!")
        } else {
            try FileHandle.standardOutput.write(contentsOf: response)
        }
    }
}
