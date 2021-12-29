//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The `Readme` file of a swift package.
///
/// Note: This implementation expects the readme file to be a ``ResourceFile``.
public class ReadMeFile: ResourceFile {
    /// Initialize a `ReadMeFile`.
    /// - Parameter name: The name of the readme file (including file extension).
    public init(_ name: String = "README.md") {
        super.init(copy: Name(stringLiteral: name))
    }
}
