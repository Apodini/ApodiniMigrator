//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary

/// This type holds some context information about a proto file descriptor
struct ProtoFileContext {
    let namer: SwiftProtobufNamer
    let hasUnknownPreservingSemantics: Bool

    init(namer: SwiftProtobufNamer, hasUnknownPreservingSemantics: Bool) {
        self.namer = namer
        self.hasUnknownPreservingSemantics = hasUnknownPreservingSemantics
    }
}
