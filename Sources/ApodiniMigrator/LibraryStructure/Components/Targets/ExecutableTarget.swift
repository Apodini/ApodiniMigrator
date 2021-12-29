//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A swift executable target placed in ``Sources``.
public class Executable: Target {
    override public var type: TargetType {
        .executable
    }

    override public init(_ name: Name, @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }
}
