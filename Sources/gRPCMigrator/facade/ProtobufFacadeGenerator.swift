//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import ApodiniMigratorCompare
import SwiftProtobuf
import SwiftProtobufPluginLibrary

struct ProtobufFacadeGenerator: LibraryNode { // TODO remove this!
    private let dumpBinaryPath: Path
    private let migrationGuide: MigrationGuide

    private let modelChanges: [ModelChange]

    init(dumpPath: String, guide: MigrationGuide) {
        self.dumpBinaryPath = Path(dumpPath)
        self.migrationGuide = guide

        self.modelChanges = migrationGuide.modelChanges
    }

    func handle(at path: PathKit.Path, with context: MigrationContext) throws {
        let data = try dumpBinaryPath.read()

        let request: Google_Protobuf_Compiler_CodeGeneratorRequest
        do {
            try request = .init(serializedData: data)
        } catch {
            // TODO pack into migrator error!
            throw error
        }

        precondition(request.fileToGenerate.count == 1)
        precondition(request.protoFile.count == 1)
        var generator = CodePrinter()

        let descriptorSet = DescriptorSet(protos: request.protoFile)
        for fileName in request.fileToGenerate {
            let descriptor = descriptorSet.lookupFileDescriptor(protoName: fileName)
            try print(file: descriptor, into: &generator)

            let fileUrl: URL = (path + (fileName.replacingOccurrences(of: ".proto", with: "") + ".migrator.swift")).url
            try generator.content.write(
                to: fileUrl,
                atomically: false,
                encoding: .utf8
            )
        }
    }

    private func print(file: FileDescriptor, into generator: inout CodePrinter) throws {
        generator.print("// COPYRIGHT NOTICE TODO\n")
        generator.print("\n")
        generator.print("import _PB_GENERATED\n")
        // generator.print("import SwiftProtobuf\n") // TODO needed?

        let namer = SwiftProtobufNamer(currentFile: file, protoFileToModuleMappings: ProtoFileToModuleMappings())

        for message in file.messages {
            let migrator = MessageMigrator(message, namer: namer, modelChanges: modelChanges)
            try migrator.migrate(into: &generator)
        }
    }
}
