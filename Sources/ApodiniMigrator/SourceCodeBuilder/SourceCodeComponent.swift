//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents any element which can be part of source code.
///
/// This is the core building block of the ``SourceCodeComponentBuilder`` and ``SourceCodeBuilder``.
public protocol SourceCodeComponent {
    /// Called to render the source code of the `SourceCodeComponent`.
    /// - Returns: Returns an array of lines.
    func render() -> [String]
}

extension String: SourceCodeComponent {
    /// Every String is interpreted as a single line in the resulting code file.
    public func render() -> [String] {
        self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }
    }
}
