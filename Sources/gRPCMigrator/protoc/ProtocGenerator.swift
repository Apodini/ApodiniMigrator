//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit
import ApodiniMigrator

struct ProtocGenerator: LibraryNode {
    let pluginName: String
    let protoPath: String
    let protoFile: String
    let options: [String: String]
    let environment: [String: String]?

    init(
        pluginName: String,
        protoPath: String,
        protoFile: String,
        options: [String: String],
        environment: [String: String]? = nil
    ) {
        self.pluginName = pluginName
        self.protoPath = protoPath
        self.protoFile = protoFile
        self.options = options
        self.environment = environment
    }

    public func handle(at path: Path, with context: MigrationContext) throws {
        guard let protocBinary = findExecutable(named: "protoc") else {
            // TODO raise migrator error
            fatalError("It seems like the `protoc` compiler isn't installed!")
        }

        var args: [String] = [
            "--\(pluginName)_out=\(path.description)",
            "--proto_path=\(protoPath)"
        ]

        if !options.isEmpty {
            args.append("--\(pluginName)_opt=\(options.map { "\($0)=\($1)" }.joined(separator: ","))")
        }

        args.append(protoFile)

        try shell(
            executableURL: protocBinary,
            args,
            environment: environment
        )
    }
}
