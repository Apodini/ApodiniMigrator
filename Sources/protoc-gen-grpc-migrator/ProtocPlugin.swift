//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import ArgumentParser
import SwiftProtobufPluginLibrary

func logError(_ message: String) { // TODO needed?
    guard let data = message.appending("\n").data(using: .utf8) else {
        fatalError("Failed to write error log: \(message)")
    }
    FileHandle.standardError.write(data)
    // TODO instead make response file with an error!
}

@main
struct ProtocPluginBoostrap: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "asdf",
        version: "0.1.2"
    )

    @Argument(completion: .directory)
    var path: String = ""

    func run() throws {
        let requestData: Data

        if !path.isEmpty { // for debug purposes, file can be supplied by cli argument
            print("Reading data from location: \(path)")
            try requestData = Data(contentsOf: URL(fileURLWithPath: path))
        } else {
            guard let stdInData = try FileHandle.standardInput.readToEnd() else {
                fatalError("Failed to read from stdin!")
            }
            requestData = stdInData
        }

        let request = try Google_Protobuf_Compiler_CodeGeneratorRequest(serializedData: requestData)

        let options = try PluginOptions(parameter: request.parameter)

        var plugin = try ProtocPlugin(request: request, options: options)

        // TODO add support for a (debug) command line flags?
        try plugin.generate()

        let response = try plugin.response.serializedData()
        try  FileHandle.standardOutput.write(contentsOf: response)
    }
}

struct ProtocPlugin {
    let request: Google_Protobuf_Compiler_CodeGeneratorRequest
    let options: PluginOptions

    let migrationGuide: MigrationGuide
    let descriptorSet: DescriptorSet

    var response = Google_Protobuf_Compiler_CodeGeneratorResponse(
        files: [],
        supportedFeatures: [.proto3Optional] // TODO do we really?
    )

    public init(request: Google_Protobuf_Compiler_CodeGeneratorRequest, options: PluginOptions) throws {
        self.request = request
        self.options = options

        if let path = options.migrationGuidePath {
            try self.migrationGuide = MigrationGuide.decode(from: Path(path))
        } else {
            self.migrationGuide = .empty()
        }
        self.descriptorSet = DescriptorSet(protos: request.protoFile)
    }

    mutating func generate() throws {
        for name in request.fileToGenerate {
            let fileDescriptor = descriptorSet.lookupFileDescriptor(protoName: name)

            let namer = SwiftProtobufNamer(
                 currentFile: fileDescriptor,
                 protoFileToModuleMappings: .init() // TODO pass some options?
            )

            try generateModelsFile(for: fileDescriptor)
            try generateServiceFile(for: fileDescriptor)
        }
    }

    mutating func generateServiceFile(for descriptor: FileDescriptor, namer: SwiftProtobufNamer) throws {
        if descriptor.services.isEmpty {
            return
        }

        let grpcFileName = "\(descriptor.name).grpc.swift" // TODO generate

        let file = GRPCClientsFile(descriptor, migrationGuide: migrationGuide, namer: namer)

        let generatedFile = Google_Protobuf_Compiler_CodeGeneratorResponse.File(
            name: grpcFileName,
            content: file.renderableContent
        )
        response.file.append(generatedFile)
    }

    mutating func generateModelsFile(for descriptor: FileDescriptor, namer: SwiftProtobufNamer) throws {
        if descriptor.messages.isEmpty && descriptor.enums.isEmpty {
            return // TODO complete check above?
        }

        let fileName = "\(descriptor.name).pb.swift" // TODO generate?

        let file = GRPCModelsFile(descriptor, migrationGuide: migrationGuide, namer: namer)

        let generatedFile = Google_Protobuf_Compiler_CodeGeneratorResponse.File(
            name: fileName,
            content: file.renderableContent
        )
        response.file.append(generatedFile)
    }

    @discardableResult
    private func generateFromStdin() throws -> Int32 {
        guard let requestData = try FileHandle.standardInput.readToEnd() else {
            fatalError("Failed to readToEnd() from stdIn!")
        }

        // TODO "PROTOC_GEN_SWIFT_LOG_REQUEST"

        let request: Google_Protobuf_Compiler_CodeGeneratorRequest
        do {
            try request = Google_Protobuf_Compiler_CodeGeneratorRequest(serializedData: requestData)
        } catch {
            Stderr.print("Request failed to decode: \(error)")
            return 1
        }

        // TODO parse potential options: `request.parameter`

        let generator = CodePrinter()

        // request.protoFile.first?.sourceCodeInfo

        let json: String
        do {
            try json = request.jsonString()
        } catch {
            Stderr.print("Failed to convert to json string: \(error)")
            return 1
        }

        let url = URL(fileURLWithPath: "./TESTFILES/dump.json")
        do {
            try json.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            Stderr.print("Failed to write dump data: \(error)")
            return 1
        }

        return 0
    }
}

class Stderr { // TODO rename/redo?
    static func print(_ s: String) {
        let out = "\(s)\n"
        if let data = out.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
