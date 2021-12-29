//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public extension Placeholder {
    /// The global `PACKAGE_NAME` placeholder, which can be used to insert the Swift package name
    /// into a ``Name``.
    static var packageName: Placeholder {
        Placeholder("PACKAGE_NAME")
    }
}

public extension Name {
    /// The global `PACKAGE_NAME` placeholder, which can be used to insert the Swift package name
    /// into a ``Name``.
    static var packageName: Name {
        "\(.packageName)"
    }
}
