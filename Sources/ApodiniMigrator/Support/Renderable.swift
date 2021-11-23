//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol for types that render a string content
protocol Renderable { // TODO remove?
    /// A functions that returns the string content of a `Renderable` instance
    func render() -> String
}

// MARK: -
extension Renderable {
    /// Returns the formatted content of `render`
    func indentationFormatted() -> String {
        render().indentationFormatted()
    }
}
