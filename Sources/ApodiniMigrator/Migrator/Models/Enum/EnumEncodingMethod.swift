//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents `encode(to:)` method of an Enum object
struct EnumEncodingMethod: Renderable {
    /// Renders the content of the method in a non-formatted way
    func render() -> String {
        """
        public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
                
        try container.encode(try encodableValue().rawValue)
        }
        """
    }
}
