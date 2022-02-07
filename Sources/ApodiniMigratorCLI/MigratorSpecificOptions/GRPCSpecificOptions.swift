//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ArgumentParser

struct GRPCSpecificOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Path where the grpc proto file is located, e.g. /path/to/MyWebService.proto",
        completion: .file(extensions: ["proto"])
    )
    var protoPath: String

    @Option(name: .long, help: "Specify the path to which you want to dump the protoc plugin request binary. For Debugging purposes!")
    var protocGenDumpRequestPath: String = ""

    @Option(name: .long, help: "Manually specify the path to the `protoc-gen-grpc-migrator` protoco plugin.")
    var protocGrpcPluginPath: String = ""
}
