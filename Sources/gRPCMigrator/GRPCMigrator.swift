//
// Created by Andreas Bauer on 14.11.21.
//

import Foundation
import MigratorAPI
import ApodiniMigratorCompare
import PathKit

public struct GRPCMigrator: Migrator {
    private static let DUMP_PATH = "/Users/andi/XcodeProjects/TUM/ApodiniMigrator/TESTFILES/dump.pbinary"

    public var bundle: Bundle = Bundle.module

    private let protoFilePath: Path
    private let protoFile: String

    private let migrationGuide: MigrationGuide

    // TODO properly source the Migration Guide!
    public init(protoFilePath: String, protoFile: String, migrationGuide: MigrationGuide) {
        // TODO support multiple proto file (non priority though)
        self.protoFilePath = Path(protoFilePath)
        self.protoFile = protoFile

        // TODO verify MigrationGuide ID(?)
        // TODO create generalized Migrator error thrown by below migrators!

        // TODO handle?
        let scripts = migrationGuide.scripts
        let jsonValues = migrationGuide.jsonValues

        let changes = migrationGuide.changes
        // let endpointChanges = changes.filter { $0.element.isEndpoint }
        // self.modelChanges = changes.filter { $0.element.isModel }
        self.migrationGuide = migrationGuide
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

            // TODO face generator! => wee need access to the dump.pbinary
            Target("_PB_FACADE") {
                ResourceFile(copy: "PBFacadeAPI.swift", to: "PBUtils.swift")

                ProtobufFacadeGenerator(
                    dumpPath: GRPCMigrator.DUMP_PATH,
                    guide: migrationGuide
                )
            }
                .dependency(target: "_PB_GENERATED")


            Target("_GRPC_GENERATED") {
                ProtocGenerator(
                    pluginName: "grpc-swift",
                    protoPath: protoFilePath.description,
                    protoFile: protoFile,
                    options: [
                        "Visibility": "Public",
                        "ExperimentalAsyncClient": "true",
                        "Server": "false"
                    ]
                )

                // we use that as a workaround avoid putting an import statement in every file
                ResourceFile(copy: "GRPCExports.swift", to: "Exports.swift")
            }
                .dependency(product: "GRPC", of: "grpc-swift")

            Target("_GRPC_FACADE")
                .dependency(target: "_GRPC_GENERATED")


            Target(GlobalPlaceholder.$packageName) {
                Directory("Networking") {
                    ResourceFile(copy: "GRPCNetworking.swift")
                }
            }
                .dependency(target: "_PB_FACADE")
                .dependency(target: "_GRPC_FACADE")
                .dependency(product: "GRPC", of: "grpc-swift")
        }

        SwiftPackageFile(swiftTools: "5.5")
            .dependency(url: "https://github.com/grpc/grpc-swift.git", ".exact(\"1.4.1-async-await.3\")")
            .product(library: GlobalPlaceholder.$packageName, targets: [[GlobalPlaceholder.$packageName]]) // TODO double array

        ReadMeFile()
    }
}
