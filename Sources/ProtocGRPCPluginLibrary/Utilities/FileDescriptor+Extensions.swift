//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary

extension FileDescriptor {
    /// FileName used for the generated file
    var fileName: String {
        !package.isEmpty ? package : name
    }

    var hasUnknownPreservingSemantics: Bool {
        syntax == .proto3
    }
}
