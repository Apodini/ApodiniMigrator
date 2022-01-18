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
    @Option(name: .shortAndLong, help: "Path where the grpc proto file is located, e.g. /path/to/MyWebService.proto")
    var protoPath: String // TODO multiple files?
}
