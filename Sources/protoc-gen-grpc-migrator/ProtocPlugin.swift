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

    let apiDocument: APIDocument
    let migrationGuide: MigrationGuide
    let descriptorSet: DescriptorSet

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
        self.apiDocument = try APIDocument.decode(from: Path(documentPath))

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
