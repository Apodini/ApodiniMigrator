//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The `Sources` folder in a swift package.
public class Sources: Directory, TargetContainingDirectory {
    public var targets: [TargetDirectory] {
        content.compactMap { $0 as? TargetDirectory }
    }

    public init(@TargetLibraryComponentBuilder<Target> content: () -> [LibraryComponent] = { [] }) {
        super.init("Sources", content: content)
    }
}
