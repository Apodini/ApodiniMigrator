//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The `Sources` folder in a swift package.
public class Sources: Directory, TargetContainingDirectory {
    public var targets: [TargetDirectory] {
        content as! [TargetDirectory] // swiftlint:disable:this force_cast
    }

    public init(@TargetLibraryComponentBuilder<Target> content: () -> [TargetDirectory] = { [] }) {
        super.init("Sources", content: content)
    }
}
