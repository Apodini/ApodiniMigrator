//
// Created by Andreas Bauer on 21.11.21.
//

import Foundation
import MigratorAPI
import ApodiniMigrator
import SwiftProtobuf
import SwiftProtobufPluginLibrary

struct ProtobufFacadeGenerator: LibraryNode {
    private let dumpBinaryPath: Path
    private let migrationGuide: MigrationGuide

    private let modelChanges: [Change]

    init(dumpPath: String, guide: MigrationGuide) {
        self.dumpBinaryPath = Path(dumpPath)
        self.migrationGuide = guide

        self.modelChanges = migrationGuide.changes.filter { $0.element.isModel }
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
            Swift.print(fileName)

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

