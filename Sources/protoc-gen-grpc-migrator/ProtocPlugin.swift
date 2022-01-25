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
                    FileHandle.standardError.write("Failed to write PROTOC_GEN_GRPC_DUMP to \(debugDumpPath): \(error)".data(using: .utf8)!)
                }
            }
        }

        let request = try Google_Protobuf_Compiler_CodeGeneratorRequest(serializedData: requestData)

        let options = try PluginOptions(parameter: request.parameter)

        var plugin = try ProtocPlugin(request: request, options: options)

        // TODO add support for a (debug) command line flags?
        try plugin.generate()

        let response = try plugin.response.serializedData()
        try FileHandle.standardOutput.write(contentsOf: response)
    }
}

struct ProtocPlugin {
    private let request: Google_Protobuf_Compiler_CodeGeneratorRequest
    private let options: PluginOptions

    private let apiDocument: APIDocument
    private let migrationGuide: MigrationGuide
    private let descriptorSet: DescriptorSet

    var response = Google_Protobuf_Compiler_CodeGeneratorResponse(
        files: [],
        supportedFeatures: [.proto3Optional]
    )

    init(request: Google_Protobuf_Compiler_CodeGeneratorRequest, options: PluginOptions) throws {
        self.request = request
        self.options = options

        guard let documentPath = options.documentPath else {
            fatalError("Tried to boot protoc plugin without specifying the APIDocument path!")
        }

        var apiDocument = try APIDocument.decode(from: Path(documentPath))
        var migrationGuide: MigrationGuide

        if let path = options.migrationGuidePath {
            try migrationGuide = MigrationGuide.decode(from: Path(path))
        } else {
            migrationGuide = .empty()
        }
        self.descriptorSet = DescriptorSet(protos: request.protoFile)

        apiDocument.combineEndpointParametersIntoWrappedType(
            considering: &migrationGuide,
            using: GRPCMethodParameterCombination()
        )

        self.apiDocument = apiDocument
        self.migrationGuide = migrationGuide
    }

    mutating func generate() throws {
        for name in request.fileToGenerate {
            let fileDescriptor = descriptorSet.lookupFileDescriptor(protoName: name)

            let namer = SwiftProtobufNamer(
                 currentFile: fileDescriptor,
                 protoFileToModuleMappings: .init() // TODO pass some options?
            )
            let context = ProtoFileContext(
                namer: namer,
                options: options,
                hasUnknownPreservingSemantics: fileDescriptor.hasUnknownPreservingSemantics
            )

            try generateModelsFile(for: fileDescriptor, context: context)
            try generateServiceFile(for: fileDescriptor, context: context)
        }
    }

    mutating func generateServiceFile(for descriptor: FileDescriptor, context: ProtoFileContext) throws {
        if descriptor.services.isEmpty {
            return
        }

        let grpcFileName = "\(descriptor.name).grpc.swift" // TODO generate filename

        let file = GRPCClientsFile(descriptor, context: context, migrationGuide: migrationGuide)

        let generatedFile = Google_Protobuf_Compiler_CodeGeneratorResponse.File(
            name: grpcFileName,
            content: file.renderableContent
        )
        response.file.append(generatedFile)
    }

    mutating func generateModelsFile(for descriptor: FileDescriptor, context: ProtoFileContext) throws {
        if descriptor.messages.isEmpty && descriptor.enums.isEmpty {
            return
        }

        let fileName = "\(descriptor.name).pb.swift" // TODO generate filename

        let file = GRPCModelsFile(descriptor, context: context, document: apiDocument, migrationGuide: migrationGuide)

        let generatedFile = Google_Protobuf_Compiler_CodeGeneratorResponse.File(
            name: fileName,
            content: file.renderableContent
        )
        response.file.append(generatedFile)
    }
}
