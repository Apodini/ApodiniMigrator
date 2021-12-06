//
// Created by Andreas Bauer on 05.12.21.
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
