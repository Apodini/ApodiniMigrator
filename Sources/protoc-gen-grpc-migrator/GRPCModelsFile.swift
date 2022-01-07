//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobufPluginLibrary

class GRPCModelsFile: SourceCodeRenderable {
    let protoFile: FileDescriptor
    let migrationGuide: MigrationGuide
    let protobufNamer: SwiftProtobufNamer

    var messages: [String: GRPCMessage] = [:]

    init(_ file: FileDescriptor, migrationGuide: MigrationGuide) {
        self.protoFile = file
        self.migrationGuide = migrationGuide
        self.protobufNamer = SwiftProtobufNamer( // TODO generate a single namer for clients and models!
            currentFile: file,
            protoFileToModuleMappings: .init() // TODO pass some options?
        )

        for message in file.messages {
            self.messages[message.name] = GRPCMessage(descriptor: message)
        }
    }

    var renderableContent: String {
        """
        // DO NOT EDIT:
        //
        // This file is machine generated!

        """

        Import(.foundation)
        if !SwiftProtobufInfo.isBundledProto(file: protoFile.proto) {
            Import("\(protobufNamer.swiftProtobufModuleName)") // TODO import SwiftProtobuf
        }
        ""
        // TODO generatorOptions.protoToModuleMappings.neededModules(forFile: fileDescriptor)

        // TODO version check?

        // TODO proto2 extension syntax: `ExtensionSetGenerator`

        // TODO `EnumGenerator`

        for message in messages.values {
            message.primaryStruct
            // TODO generateCaseIterable for nested enums?
        }

        // TODO generate extension set stuff?

        // TODO enums runtime support!

        for message in messages.values {
            message.runtimeSupport
        }

        // TODO `_protobuf_package` thingy?
        // TODO "generateRuntimeSupport"  for enums and message
    }
}
