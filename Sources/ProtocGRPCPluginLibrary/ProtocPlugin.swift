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

public struct ProtocPlugin {
    private let request: Google_Protobuf_Compiler_CodeGeneratorRequest
    private let options: PluginOptions

    private let migration: MigrationContext
    private let descriptorSet: DescriptorSet

    public var response = Google_Protobuf_Compiler_CodeGeneratorResponse(
        files: [],
        supportedFeatures: [.proto3Optional]
    )

    public init(request: Google_Protobuf_Compiler_CodeGeneratorRequest, options: PluginOptions) throws {
        self.request = request
        self.options = options

        guard let documentPath = options.documentPath else {
            fatalError("Tried to boot protoc plugin without specifying the APIDocument path!")
        }

        let apiDocument = try APIDocument.decode(from: Path(documentPath))
        let migrationGuide: MigrationGuide

        if let path = options.migrationGuidePath {
            try migrationGuide = MigrationGuide.decode(from: Path(path))
        } else {
            migrationGuide = .empty()
        }

        self.migration = MigrationContext(document: apiDocument, migrationGuide: migrationGuide)
        self.descriptorSet = DescriptorSet(protos: request.protoFile)
    }

    public mutating func generate() throws {
        for name in request.fileToGenerate {
            let fileDescriptor = descriptorSet.lookupFileDescriptor(protoName: name)

            let namer = SwiftProtobufNamer(
                 currentFile: fileDescriptor,
                 protoFileToModuleMappings: .init() // protoFileToModuleMappings is unsupported
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

        let grpcFileName = "\(descriptor.fileName).grpc.swift"

        let file = GRPCClientsFile(descriptor, context: context, migration: migration)

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

        let fileName = "\(descriptor.fileName).pb.swift"

        let file = GRPCModelsFile(descriptor, context: context, migration: migration)

        let generatedFile = Google_Protobuf_Compiler_CodeGeneratorResponse.File(
            name: fileName,
            content: file.renderableContent
        )
        response.file.append(generatedFile)
    }
}
