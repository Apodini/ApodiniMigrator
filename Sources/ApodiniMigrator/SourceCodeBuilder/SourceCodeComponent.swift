//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol SourceCodeComponent {
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
