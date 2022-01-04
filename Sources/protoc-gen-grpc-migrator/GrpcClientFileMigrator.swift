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

class GRPCClientFile: SourceCodeRenderable {
    let protoFile: FileDescriptor
    let migrationGuide: MigrationGuide

    let protobufNamer: SwiftProtobufNamer

    init(_ file: FileDescriptor, migrationGuide: MigrationGuide) {
        self.protoFile = file
        self.migrationGuide = migrationGuide
        self.protobufNamer = SwiftProtobufNamer(
            currentFile: file,
            protoFileToModuleMappings: .init() // TODO pass some options?
        )
    }

    var renderableContent: String {
        """
        // DO NOT EDIT.
        //
        // This file is machine generated!

        """

        Import("NIO")
        Import("GRPC")
        // TODO other imports
        ""

        // TODO search through the list off "added endpoints", derrive there identifiers (Client Name + rpcName)
        //  => group them into the below services!
        //  => such that they can be generated (just by the endpoint/typeInfo description!)
        for service in protoFile.services {
            GRPCService(service, locatedIn: self)
        }
    }
}
