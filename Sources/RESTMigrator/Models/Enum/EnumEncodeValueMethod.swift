//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents the `encodableValue()` util method in an enum
struct EnumEncodeValueMethod: SourceCodeRenderable {
    /// Renders the content of the initializer in a non-formatted way
    var renderableContent: String {
        "private func encodableValue() throws -> Self {"
        Indent {
            "let deprecated = Self.\(EnumDeprecatedCases.variableName)"
            "guard deprecated.contains(self) else {"
            Indent {
                "return self"
            }
            "}"

            "throw ApodiniError(code: 404, message: \"The web service does not support the cases of this enum anymore\")"
        }
        "}"
    }
}
