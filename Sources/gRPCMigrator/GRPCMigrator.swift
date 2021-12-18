//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import ApodiniMigratorCompare
import Logging // TODO depdndency?

public struct GRPCMigrator: Migrator {
    private static let DUMP_PATH = "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/dump.pbinary"

    public var bundle: Bundle = .module

    public static let logger: Logger = {
        .init(label: "org.apodini.migrator.grpc")
    }()

    private let protoFilePath: Path
    private let protoFile: String

    private let migrationGuide: MigrationGuide
    private let migrationGuidePath: String?

    public init(protoFilePath: String, protoFile: String, migrationGuidePath: String? = nil) throws {
        // TODO support multiple proto file (non priority though)
        self.protoFilePath = Path(protoFilePath)
        self.protoFile = protoFile

        // TODO verify MigrationGuide ID(?)
        // TODO create generalized Migrator error thrown by below migrators!

        // TODO handle?
        // let scripts = migrationGuide.scripts
        // let jsonValues = migrationGuide.jsonValues

        // let changes = migrationGuide.changes
        // let endpointChanges = changes.filter { $0.element.isEndpoint }
        // self.modelChanges = changes.filter { $0.element.isModel }
        if let path = migrationGuidePath {
            try self.migrationGuide = MigrationGuide.decode(from: Path(path))
            self.migrationGuidePath = migrationGuidePath
        } else {
            self.migrationGuide = .empty
            self.migrationGuidePath = nil
        }
    }

    public var library: RootDirectory {
        Sources {
            Target("_PB_GENERATED") {
                ProtocGenerator(
                    pluginName: "swift",
                    protoPath: protoFilePath.description,
                    protoFile: protoFile,
                    options: ["Visibility": "Public"],
                    // TODO find a intermediate file storage path!
                    environment: ["PROTOC_GEN_SWIFT_LOG_REQUEST": GRPCMigrator.DUMP_PATH]
                )
            }
                .dependency(product: "GRPC", of: "grpc-swift")

            // TODO facade generator! => wee need access to the dump.pbinary
            Target("_PB_FACADE") {
                ResourceFile(copy: "PBFacadeAPI.swift", to: "PBUtils.swift")

                ProtobufFacadeGenerator(
                    dumpPath: GRPCMigrator.DUMP_PATH,
                    guide: migrationGuide
                )
            }
                .dependency(target: "_PB_GENERATED")


            Target("_GRPC") {
                ProtocGenerator(
                    pluginName: "grpc-migrator",
                    protoPath: protoFilePath.description,
                    protoFile: protoFile,
                    options: [
                        "Visibility": "Public",
                        "MigrationGuide": migrationGuidePath ?? ""
                        // "ExperimentalAsyncClient": "true",
                        // "Server": "false"
                    ]
                )

                // we use that as a workaround avoid putting an import statement in every file
                ResourceFile(copy: "GRPCExports.swift", to: "Exports.swift")
            }
                .dependency(product: "GRPC", of: "grpc-swift")


            Target(GlobalPlaceholder.$packageName) {
                Directory("Networking") {
                    ResourceFile(copy: "GRPCNetworking.swift")
                }
            }
                .dependency(target: "_PB_FACADE")
                .dependency(target: "_GRPC")
                .dependency(product: "GRPC", of: "grpc-swift")
        }

        SwiftPackageFile(swiftTools: "5.5")
            .platform(".macOS(.v12)", ".iOS(.v14)")
            .dependency(url: "https://github.com/grpc/grpc-swift.git", ".exact(\"1.6.1-async-await.1\")")
            .product(library: GlobalPlaceholder.$packageName, targets: [[GlobalPlaceholder.$packageName]])

        ReadMeFile()
    }
}
