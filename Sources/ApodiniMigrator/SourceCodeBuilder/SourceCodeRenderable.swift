//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Any element which can be rendered to source code using ``SourceCodeBuilder``.
public protocol SourceCodeRenderable: SourceCodeComponent {
    /// The rendered source code content.
    @SourceCodeBuilder
    var renderableContent: String { get }
}

public extension SourceCodeRenderable {
    /// Default implementation for the render method based on the `renderableContent` property.
    func render() -> [String] {
        renderableContent
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }
    }
}
