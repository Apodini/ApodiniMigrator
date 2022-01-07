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
import OrderedCollections

class GRPCEnum {
    let descriptor: EnumDescriptor
    let namer: SwiftProtobufNamer

    init(descriptor: EnumDescriptor, namer: SwiftProtobufNamer) {
        self.descriptor = descriptor
        self.namer = namer
    }

    @SourceCodeBuilder
    var primaryModelType: String {
        "// GENERATION OF ENUM \(descriptor.name) UNSUPPORTED"
    }

    @SourceCodeBuilder
    var protobufferRuntimeSupport: String {
        "// RUNTIME GENERATION OF ENUM \(descriptor.name) UNSUPPORTED"
    }
}
