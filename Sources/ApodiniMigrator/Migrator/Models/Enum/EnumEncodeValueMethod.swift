//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents the `encodableValue()` util method in an enum
struct EnumEncodeValueMethod: Renderable {
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        private func encodableValue() throws -> Self {
        let deprecated = Self.\(EnumDeprecatedCases.variableName)
        guard deprecated.contains(self) else {
        return self
        }
        if let alternativeCase = Self.allCases.first(where: { !deprecated.contains($0) }) {
        return alternativeCase
        }
        throw ApodiniError(code: 404, message: "The web service does not support the cases of this enum anymore")
        }
        """
    }
}
